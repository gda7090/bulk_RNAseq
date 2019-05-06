library(ggplot2)
library(alakazam)
library(lazyeval)
library("dplyr")
source("alakazam/alakazam/R/Diversity.R")
source("alakazam/alakazam/R/Core.R")
#setwd('C:\\Users\\xgl\\NJ_project')
#png(file="myplot.png", bg="white")
datain <- read.delim('02.mixcr/all_sample.abundance', header = TRUE)

estimateAbun<-function(data, group=NULL, clone="CLONE", copy=NULL, ci=0.95,
                              nboot=2000, progress=FALSE) {
    ## DEBUG
    # group="SAMPLE"; clone="CLONE"; copy="UID_CLUSTCOUNT"; ci=0.95; nboot=200
    # data=clones; group="SUBJECT"; clone="CLONE"; copy=NULL; ci=0.95; nboot=200; progress=FALSE

    # Check input
    if (!is.data.frame(data)) {
        stop("Input data is not a data.frame")
    }
    check <- checkColumns(data, c(group, clone, copy))
    if (check != TRUE) { stop(check) }

    # Tabulate clonal abundance
    if (is.null(copy)) {
        clone_tab <- data %>%
            group_by_(.dots=c(group, clone)) %>%
            dplyr::summarize(COUNT=n())
    } else {
        clone_tab <- data %>%
            group_by_(.dots=c(group, clone)) %>%
            dplyr::summarize_(COUNT=interp(~sum(x, na.rm=TRUE), x=as.name(copy)))
    }

    # Set confidence interval
    ci_z <- ci + (1 - ci) / 2

    if (!is.null(group)) {
        # Summarize groups
        group_tab <- clone_tab %>%
            group_by_(.dots=c(group)) %>%
            dplyr::summarize_(SEQUENCES=interp(~sum(x, na.rm=TRUE), x=as.name("COUNT")))
        group_set <- as.character(group_tab[[group]])
        nsam <- setNames(group_tab$SEQUENCES, group_set)

        # Generate diversity index and confidence intervals via resampling
        if (progress) {
            pb <- progressBar(length(group_set))
        }
        abund_list <- list()
        for (g in group_set) {
            n <- nsam[g]

            # Extract abundance vector
            abund_obs <- clone_tab$COUNT[clone_tab[[group]] == g]
            #names(abund_obs) <- clone_tab$CLONE[clone_tab[[group]] == g]

            # Infer complete abundance distribution
            abund_list[[g]] <- bootstrapAbundance(abund_obs, n, z=ci_z, nboot=nboot)

            if (progress) { pb$tick() }
        }
        curve_df <- as.data.frame(bind_rows(abund_list, .id="GROUP"))
    } else {
        # Summarize counts
        group_set <- as.character(NA)
        nsam <- sum(clone_tab$COUNT, na.rm=TRUE)

        # Extract abundance vector
        abund_obs <- clone_tab$COUNT
        names(abund_obs) <- clone_tab$CLONE

        # Infer complete abundance distribution
        curve_df <- bootstrapAbundance(abund_obs, nsam, z=ci_z, nboot=nboot)
        curve_df$GROUP <- NA
    }
    # Generate return object
    curve <- new("AbundanceCurve",
                 data=curve_df,
                 groups=group_set,
                 n=nsam,
                 nboot=nboot,
                 ci=ci)

    return(curve)
}

clones <- estimateAbun(datain, group="SAMPLE", copy="DUPCOUNT", ci=0.95, nboot=200)
#sample_colors <- c("A_1"="seagreen", "A_2"="steelblue")
#, "IgM_3"="red")
p<-plotAbundanceCurve(clones, legend_title="Sample")
ggsave("abundance.pdf", plot=p, width=8, height=6)
ggsave("abundance.png", plot=p, width=8, height=6, type="cairo-png")

#isotype_div <- rarefyDiversity(datain, "SAMPLE", min_q=0, max_q=32, step_q=0.05, ci=0.95, nboot=200)
#isotype_main <- paste0("Isotype diversity (n=", isotype_div@n, ")")
#p<-plotDiversityCurve(isotype_div, main_title=isotype_main, legend_title="Sample", log_q=TRUE, log_d=TRUE)
#ggsave("isotype_div.pdf", plot=p, width=8, height=6)
#ggsave("isotype_div.png", plot=p, width=8, height=6, type="cairo-png")

sample_div <- rarefyDiversity(datain, "SAMPLE", min_q=0, max_q=32, step_q=0.05, ci=0.95, nboot=200)
sample_main <- paste0("Sample diversity (n=", sample_div@n, ")")
p<-plotDiversityCurve(sample_div, main_title=sample_main, 
                  legend_title="Sample", log_x=TRUE, log_y=TRUE)
ggsave("diversity.pdf", plot=p, width=8, height=6)
ggsave("diversity.png", plot=p, width=8, height=6, type="cairo-png")
