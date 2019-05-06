# -*- coding: utf-8 -*-

## start
from __future__ import print_function
__version__ = 2.0               # try to obtain output structure Genomic_Feature/{coding, non_coding, all}
import os, sys
from os.path import *
import re
from pprint import pprint
from itertools import islice
import pprint as pp

import pdb
import HTSeq
from collections import defaultdict, OrderedDict

import logging
import argparse

## argparse
parser = argparse.ArgumentParser(
    description="get promoter sequences from gtf files and fa"
)
parser.add_argument("--gtf",help='gtf file',required=True)
parser.add_argument("--fa",help='fa file',required=True)
parser.add_argument("--pl", "--promoter_length",help='promoter_length',type=int, default=2000)
parser.add_argument("--genenamefile",help='genename file [unimplemented]',required=False)
parser.add_argument("--outdir",help='output folder, if it contains Genomic_Feature subfolder, then files may be overwritten',
                    default=".")
parser.add_argument("--format",choices=("gff",'gtf'),default="gtf")
parser.add_argument("--workflow",help="which workflow you want to use, default is 0, which is autodetect",default=0,type=int)
parser.add_argument("--debug",action='store_true',default=False)
parser.add_argument("--no_whole_report",action='store_true',default=False)
parser.add_argument("--test_line",type=int, default=0)
args = parser.parse_args()
if args.debug:
    logging.basicConfig(level=logging.DEBUG)


outdir = abspath(args.outdir)
if(not exists(outdir)):
    try:
        os.mkdir(outdir)
    except Exception, e:
        raise e, "Folder {outdir} can not be created!".format(outdir = outdir)
for x in ["all","non_coding","coding"]:
    if not isdir(join(outdir, x)):
        try:
            os.mkdir(join(outdir, x))
        except Exception, e:
            raise e, "subfolder '{x}' under '{outdir}' cannot be created!".format(**locals())


## * ######################### generate fai files #########################
faidx = "%s.fai" % args.fa
if not exists(faidx):
    assert not os.system("samtools faidx %s" % args.fa)

## * ########################## parse faidx file ##########################
chr_lengths = OrderedDict()
for line in open(faidx):
    temp = line.strip().split("\t")
    chr_id = temp[0]
    chr_length = int(temp[1])
    chr_lengths[chr_id] = chr_length
print("chr_lengths produced!", file=sys.stderr)


## * ####################### get guoyang's functions #######################
#DMR/annotation_region_v2.py

def order_iv2(ls, strand="+"):              # sort iv by start_d
    return sorted(ls, key = lambda x:(x.start_d, x.end_d), reverse = (strand != "+"))

def order_feature2(ls, strand = "+"):
    return sorted(ls, key = lambda x:(x.iv.start_d, x.iv.end_d), reverse = (strand != "+"))

def str_iv2(iv,tid):            # should be the same
    """output to bed file format
    :param iv: GenomicInterval object
    :param tid: transcript id (this entry can contain annotations)
    :returns: string
    :rtype: str
    """
    tid = re.sub("%s:" % iv.chrom,"",tid)
    return "\t".join([
        iv.chrom, # chromosome id
        str(iv.start), # interval start
        str(iv.end),   # interval end
        tid,      # transcript id
        ".",      # ?
        iv.strand # strand
        ]) + "\n"

## * ######################## generate transcripts ########################

def simple_names(str1):
    return re.sub('[ /]', "_", str1)

fhandlers = set()

class featureList(object):
    """featureList should be used in transcript-wise way"""
    def __init__(self, ls=[]):
        "this is a list and dict mixture with sth. special for GenomicFeature objects"
        self.features = []
        self.feature_dict = defaultdict(list)
        self.gene = None
        self.types = set()
        self.type_length = None
        self.current_item = None
        ## real running
        self.extend(ls)
        self.tag = None

    def append(self,item):      # this should be the only way to append a feature
        assert isinstance(item, HTSeq.GenomicFeature), "item %s should be an instance of HTSeq.GenomicFeature" % item
        assert item.iv.strand in ("+","-"), \
            "GenomicFeature %s should contain strand in either + or -," \
            " which is %s" % (item, item.iv.strand)
        self.current_item = item
        if self.already_has_feature(item):  # deduplication
            return
        self.features.append(item)
        self.feature_dict[item.type].append(item)
        self.types.add(item.type)

    def already_has_feature(self, item):  # sometimes gtf may have duplicated lines
        for feature in self.features:
            if item.iv == feature.iv and feature.type == item.type:
                return True
        return False

    def extend(self,items):
        for item in items:
            self.append(item)

    def __setitem__(self,key,value):
        self.feature_dict[key] = value

    def __getitem__(self,key):
        return self.feature_dict[key]

    def sort(self):
        """both self.features and all self.feature_dict values should be sorted

        :returns: None
        :rtype: None

        """
        strand = set([x.iv.strand for x in self.features])
        assert len(strand) == 1, self.features
        self.features = order_feature2(self.features, strand = list(strand)[0])
        for x, v in self.feature_dict.iteritems():
            self.feature_dict[x] = order_feature2(v, strand = list(strand)[0])

    def biotype(self):
        r = set()
        if self.features:
            for feature in self.features:
                r = r.union([v for k,v in feature.attr.iteritems() if re.search("gene.*type",k)])
        return list(r)

    def __open_fh(self, type_name):
        """ should only be called from self.report() or self.whole_report() or self.open_fh_when_need()

        :param type_name: feature.type
        :returns: a list of file handlers
        :rtype: list

        """
        global fhandlers        # a global set
        safer_name = simple_names(type_name)
        simple_fh = "FHANDLERs_for_type_%s" % safer_name  # FHANDLERs
        if self.tag is None:    # self.tag has not been specified
            raise AssertionError, "self.tag should be populated first before self.__open_fh() is called!"
        _globals = globals()
        if not _globals.get(simple_fh, False):
            _globals[simple_fh] = {x: open(join(outdir, x, "%s.bed" % safer_name), 'w') for x in ("all","non_coding","coding")}
            fhandlers = fhandlers.union(_globals[simple_fh].values())  # fhandlers is for close() only!
        return [v for k,v in _globals[simple_fh].iteritems() if k in [self.tag, "all"]] 

    def report(self):
        self.sort()
        assert self.tag is not None, "self.tag should be populated first, before self.report() called!"
        for key, features in self.feature_dict.iteritems():  # key is type
            OUTs = self.__open_fh(key)
            for feature in features:
                annotation = feature.name
                for OUT in OUTs:
                    OUT.write(str_iv2(feature.iv, annotation))

    def whole_report(self):
        self.sort()
        assert self.tag is not None, "self.tag should be populated first, before self.report() called!"
        OUTs = self.__open_fh("whole_report")
        for feature in self.features:
            if feature.name.find("|") == -1:
                feature.name = "%s|%s|%s" % (feature.attr['transcript_id'],
                                             feature.name,
                                             feature.type)
            annotation = feature.name
            for OUT in OUTs:
                OUT.write(str_iv2(feature.iv, annotation).rstrip("\n") + "\t" + feature.type + "\n")


def generate_transcripts(file1, test=None):
    """return transcripts
    :param test: int or None, an arg passed to islice
    :param method: "type" or else
    :returns: OrderedDict()
    :rtype: 
    """
    transcripts=OrderedDict()       # this is the main data structure in this script
    gtf = HTSeq.GFF_Reader(file1)   # file1 need to be a path with ascii only
    for lineno, feature in enumerate(islice(gtf,test),1):
        if "transcript_id" not in feature.attr: # drop all lines missing transcript_id, which is rare in REAL GTF FILES
            continue
        if 'tRNAscan-SE' == feature.source:
            raise AssertionError, "gene annotation from tRNAscan-SE detected, which often cause this script crash: %s\nShould use 'grep -v <gtf>' to del these records" % feature.attr['gene_id']
        if "gene_id" in feature.attr:
            tid = feature.iv.chrom + ':' + feature.attr['transcript_id'] + '|' + feature.attr['gene_id'] # generate tid
        else:
            raise AssertionError, "gene_id or gene_name cannot be found at " \
                "feature {feature} in line {lineno} of file {file1}!".format(**locals())
        if tid not in transcripts:
            transcripts[tid] = featureList()  # TODO: this is not ideal
        transcripts[tid].append(feature)
    return transcripts


def zerolength(iv):
    return iv.start == iv.end


genes = defaultdict(list)

def construct_iv(*args, **kwargs):
    try:
        return HTSeq.GenomicInterval(*args, **kwargs)
    except Exception, e:
        pprint((args, kwargs))
        # pdb.set_trace()
        raise e

        
## * ################ workflow1: only consider CDS and exon ################
def workflow1(file1, test=None):
    """workflow1: only consider "exon" and "CDS"

    :param file1: gtf filename
    :returns: None
    :rtype: None

    """
    transcripts = generate_transcripts(file1, test)
    ## * ######################### populate bed files: merge the range #########################
    for each_trans, feature_list in transcripts.iteritems():  # each_trans are just tids, using id to maintain order
        temp = re.split("[:|]",each_trans)
        chr_gene_id = "%s:%s" % (temp[0],temp[2])
        feature_list.sort()  # sorted by start_d
        if feature_list['exon'] == [] and feature_list['CDS'] == []:
            logging.debug("BAD: {each_trans} was skipped in function workflow1 because of both CDS and exon are missing".format(
                **locals()))
            continue
        ordered_CDS=feature_list['CDS']
        if len(ordered_CDS) > 1:
            for i in range(1, len(ordered_CDS) + 1):
                ordered_CDS[i-1].name = "{each_trans}|CDS.{}".format(i, each_trans = each_trans)
        elif len(ordered_CDS) == 1:
            ordered_CDS[0].name = "%s|CDS" % each_trans
        ordered_exon=feature_list['exon']
        ## special branch with only CDS but no exon
        if len(ordered_exon) == 0:
            ordered_exon = ordered_CDS
        ## change exon name
        elif len(ordered_exon) > 1:
            for i in range(1, len(ordered_exon) + 1):
                ordered_exon[i-1].name = "{each_trans}|exon.{}".format(i, each_trans = each_trans)
        else:
            ordered_exon[0].name = "%s|exon" % each_trans
        ## normal branch, ordered_exon is main player
        chrom=ordered_exon[0].iv.chrom
        strand=ordered_exon[0].iv.strand
        biotype = feature_list.biotype()  # add tag things here, just "coding", "non_coding" for now
        feature_list.tag = "coding" if ordered_CDS != [] else "non_coding"
        if biotype:
            biotype = "|%s" % ("_".join(biotype),)  # biotype should be unique
        else:
            biotype = ""
        ## _intron
        if len(ordered_exon) == 2:
            if strand == "+":
                intron = construct_iv(chrom, ordered_exon[0].iv.end, ordered_exon[1].iv.start, strand)
            else:
                intron = construct_iv(chrom, ordered_exon[1].iv.end, ordered_exon[0].iv.start, strand)
            feature_list.append(
                HTSeq.GenomicFeature("{each_trans}|intron".format(each_trans = each_trans),
                                     "_intron", intron)
            )
        elif len(ordered_exon) > 2:
            for i in range(1,len(ordered_exon)): # get all introns
                if strand == "+":
                    intron = construct_iv(chrom, ordered_exon[i-1].iv.end, ordered_exon[i].iv.start, strand)
                else:
                    intron = construct_iv(chrom, ordered_exon[i].iv.end, ordered_exon[i-1].iv.start, strand)
                feature_list.append(
                    HTSeq.GenomicFeature("{each_trans}|intron.{}".format(i, each_trans=each_trans),
                                         "_intron", intron))
        ## gene
        if strand == "+":
            gene = construct_iv(chrom, ordered_exon[0].iv.start, ordered_exon[-1].iv.end, strand)  # gene is an iv
        else:
            gene = construct_iv(chrom, ordered_exon[-1].iv.start, ordered_exon[0].iv.end, strand)
        feature_list.append(
            HTSeq.GenomicFeature("{each_trans}{biotype}".format(
                each_trans = each_trans,
                biotype = biotype), "_transcript", gene)
        )
        if len(ordered_CDS):
            ## _utr5
            if ordered_exon[0].iv.start_d != ordered_CDS[0].iv.start_d:
                if strand == "+":
                    utr5 = construct_iv(chrom, ordered_exon[0].iv.start, ordered_CDS[0].iv.start, strand)  # temporary
                else:
                    if ordered_CDS[0].iv.end > ordered_exon[0].iv.end:
                        continue
                    utr5 = construct_iv(chrom, ordered_CDS[0].iv.end, ordered_exon[0].iv.end, strand)
                prime5_exons = [x.iv for x in ordered_exon if x.iv.overlaps(utr5)]
                if len(prime5_exons) == 1:
                    feature_list.append(
                        HTSeq.GenomicFeature(
                            "{each_trans}|utr5".format(each_trans=each_trans),
                            "_utr5", utr5))
                else:
                    for i in range(1, len(prime5_exons) + 1):
                        if i == len(prime5_exons):
                            if strand == "+":
                                i_utr5 = construct_iv(chrom, prime5_exons[-1].start, utr5.end, strand)
                            else:
                                i_utr5 = construct_iv(chrom, utr5.start, prime5_exons[-1].end, strand)
                        else:
                            i_utr5 = prime5_exons[i-1]
                        feature_list.append(
                            HTSeq.GenomicFeature(
                                "{each_trans}|utr5.{}".format(i, each_trans=each_trans),
                                "_utr5", i_utr5))
            ## stop_codon and utr3
            if ordered_CDS[-1].iv.end_d != ordered_exon[-1].iv.end_d:
                ## get utr3
                if feature_list["stop_codon"] != []:
                    if abs(ordered_CDS[-1].iv.end_d - ordered_exon[-1].iv.end_d) != 3:
                        if strand == "+":
                            utr3 = construct_iv(chrom, ordered_CDS[-1].iv.end + 3, ordered_exon[-1].iv.end, strand)
                        else:
                            utr3 = construct_iv(chrom, ordered_exon[-1].iv.start, ordered_CDS[-1].iv.start - 3, strand)
                    else:
                        utr3 = False  # this is important
                else:
                    if strand == "+":
                        if ordered_CDS[-1].iv.end > ordered_exon[-1].iv.end:
                            continue
                        utr3 = construct_iv(chrom, ordered_CDS[-1].iv.end, ordered_exon[-1].iv.end, strand)
                    else:
                        utr3 = construct_iv(chrom, ordered_exon[-1].iv.start, ordered_CDS[-1].iv.start, strand)
                if utr3:        # 有可能没有utr3
                    prime3_exons = [x.iv for x in feature_list['exon'] if x.iv.overlaps(utr3)]
                    if len(prime3_exons) == 1:
                        feature_list.append(
                            HTSeq.GenomicFeature(
                                "{each_trans}|utr3".format(each_trans=each_trans),
                                "_utr3", utr3
                            )
                        )
                    else:
                        for i in range(1, len(prime3_exons) + 1):
                            if i == 1:
                                if strand == "+":
                                    i_utr3 = construct_iv(chrom, utr3.start, prime3_exons[0].end, strand)
                                else:
                                    i_utr3 = construct_iv(chrom, prime3_exons[0].start, utr3.end, strand)
                            else:
                                i_utr3 = prime3_exons[i-1]
                            feature_list.append(
                                HTSeq.GenomicFeature(
                                    "{each_trans}|utr3.{}".format(i, each_trans=each_trans),
                                    "_utr3", i_utr3
                                )
                            )
        ## promoter
        if strand == "+":
            ps = ordered_exon[0].iv.start - args.pl # promoter start position
            if ps <0:
                ps = 0
            promoter=construct_iv(chrom, ps, ordered_exon[0].iv.start, strand)
        else:                       # if strand == "-"
            ps = ordered_exon[0].iv.end + args.pl
#             if chrom == 'scaffold_42':  ##only for debug
#                 exit( '%s ' %  ordered_exon[0].name)
            if ps > chr_lengths[chrom]:
                ps = chr_lengths[chrom]
            if ordered_exon[0].iv.end > ps:
                print ( 'skipping:%s, %s, %s, %s' % (chrom, ordered_exon[0].iv.end, ps, strand), file=sys.stderr )
                continue
            promoter=construct_iv(chrom, ordered_exon[0].iv.end, ps, strand)
        feature_list.append(
            HTSeq.GenomicFeature(
                "{each_trans}|promoter".format(each_trans=each_trans),
                "_promoter", promoter
            )
        )
        ## record
        genes[chr_gene_id].append(gene) # using chr_gene_id: "chr:gene_id"
    ## create folders
    ## write to file
    for each_trans, feature_list in transcripts.iteritems():
        feature_list.report()
        if not args.no_whole_report:
            feature_list.whole_report()
    ## close all fhandlers
    for x in fhandlers:
        try:
            x.close()
        except:
            print("file handler %s cannot be closed, maybe you have closed it?" % x)
            pass
    if test:
        pdb.set_trace()
    ## * ################### try to output intergenic region ###################
    intergenic_f = open("%s/intergenic.bed" % outdir, "w")
    outer_genes = OrderedDict()

    for chr_gene_id, gs in genes.iteritems():
        chr_id = chr_gene_id.split(":")[0]
        gene_id = chr_gene_id.split(":")[1]
        if chr_id not in outer_genes:
            outer_genes[chr_id] = {}
        if len(gs) > 1:
            gene = construct_iv(gs[0].chrom, min([x.start for x in gs]),
                                         max([x.end for x in gs]), gs[0].strand) # combine multiple transcripts of the same gene
            outer_genes[chr_id][gene_id] = gene
        else:
            outer_genes[chr_id][gene_id] = gs[0]

    for chr_id in outer_genes:
        flag = 0
        former_g = ""                   # gene before interval
        next_g = ""                     # gene after interval
        for gene_id in sorted(outer_genes[chr_id].keys(), key=lambda x: outer_genes[chr_id][x].start): # super-low efficiency
            chr_gene_id = "%s:%s" %(chr_id, gene_id)
            gene = outer_genes[chr_id][gene_id]
            e = gene.end
            s = gene.start
            assert s < e, (chr_gene_id, gene, s, e)
            if flag == s:               # does this can happen?
                flag = e
                former_g = chr_gene_id
                continue
            elif flag < s:              # normal stuff
                next_g = chr_gene_id
                _id = former_g + "--" + next_g
                inter_g = construct_iv(gene.chrom, flag, s, "+")
                intergenic_f.write(str_iv2(inter_g, _id))
                flag = e
                former_g = chr_gene_id
                continue
            elif flag >= e:
                logging.debug("Former({}) may overlap with gene_id({})".format(former_g, gene_id))
                continue
            elif flag < e:
                flag = e
                former_g = chr_gene_id
                continue

        next_g = ""
        _id = former_g + "--" + next_g
        logging.debug("{0}({1}) has start of {flag}, end of {2}".format(gene.chrom,
                                                                        chr_id,
                                                                        chr_lengths[chr_id],
                                                                        flag=flag))
        inter_g = construct_iv(gene.chrom, flag, chr_lengths[chr_id], "+")
        logging.debug("OUTPUT last interval, former is %s" % former_g)
        intergenic_f.write(str_iv2(inter_g, _id))

    intergenic_f.close()

## * #### workflow2, first convert gff file to gtf, then use workflow1 ####

def workflow2(file1, test=None):
    gtf_filename = "%s/%s.gtf" % (outdir, basename(file1))
    if not isfile(gtf_filename):
        assert not os.system("cufflinks-2.1.1/gffread -E %s -T -F -o- > %s.gffread.out" % (file1, gtf_filename))
        assert not os.system("python simplify_gtf.py %s.gffread.out > %s" % (gtf_filename, gtf_filename))
    assert isfile(gtf_filename)
    workflow1(gtf_filename, test)
    

## * ############################# auto_detect #############################
def auto_detect(lines = 1000):
    """detect GTF type based on first <lines> lines

    :param lines: number of lines for detecting
    :returns: number for workflow selection
    :rtype: int

    """
    gtf = HTSeq.GFF_Reader(args.gtf)
    has_exon = False
    has_CDS = False
    for feature in islice(gtf,lines):
        if all([has_exon, has_CDS]):  # 如果exon和CDS都存在，那么就是用workflow1
            return 1
        if feature.type == "CDS":
            has_CDS = True
        elif feature.type == "exon":
            has_exon = True
    ## after checking all <lines> lines, then we can suggest that:
    if all([not has_exon, has_CDS]):
        return 2
    return 1

## * ################################ main ################################
def main():
    if args.format == "gtf":
        if args.workflow == 0:
           args.workflow = auto_detect()
           logging.debug("auto_detect() returns %d for workflow selection" % args.workflow)
    elif args.format == "gff":
        args.workflow = 2
    else:
        print("Please check --format argument")
        sys.exit()
    if args.workflow:
        wf_function = "workflow%d" % args.workflow
        wf = globals().get(wf_function, "Function %s not found!" % wf_function)
    else:
        wf = 0
    if args.test_line <= 0:
        args.test_line = None
    wf(args.gtf, args.test_line)


if __name__ == '__main__':
    main()
