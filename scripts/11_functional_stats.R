#Genevieve Mortensen for I790 modified 02/08/2023

########################################################
### FUNCTIONAL PROFILE OF PREGNANT PERSON MICROBIOME ###
########################################################

##load libraries
library(readr)
library(heatmaply)
library(ggplot2)
library(edgeR)
library(magrittr)
library(dplyr)
library(reshape)
library(tidyr)
library(broom)

### PRELIMINARY VISUALIZATION ###

##Set working directory
#setwd("home/gamorten/prj/pergnancy/humann_work/")
setwd("C:/Users/genev/OneDrive - Indiana University/Projects/I790-Fa22")

##Retrieve data, save as dataframe
pregnant_vector <- data.frame(read_tsv('preg_gf_combined_rxn-cpm-named.tsv'))
pregnant_df <- data.frame(pregnant_vector[,-1], row.names=pregnant_vector[,1])

##Go through each row and determine if a value is zero
row_sub = apply(pregnant_df, 1, function(row) all(row !=0 ))

##Subset as new dataframe
pregnant_df_2 <- pregnant_df[row_sub,]
##Declare matrix
pregnant_mtx <- as.matrix(pregnant_df_2)

##Create heatmap
#heatmaply(pregnant_mtx, 
#          fontsize_col = 2,
#          fontsize_row = 2,
#          show_dendrogram = c(FALSE, FALSE),
#          main = "Interactive Heatmap",
#          xlab = "Sample",
#          ylab = "Pathway",
#          file = "pregnancy_pathabund_heatmap.html")

##Ref. 1: https://microbiome.github.io/tutorials/all.html
##Ref. 2: https://www.nicholas-ollberding.com/post/introduction-to-the-statistical-analysis-of-microbiome-data-in-r/
##Ref. 3: https://www.ml4microbiome.eu/wp-content/uploads/2021/11/Statistical-Analysis-of-Microbiome-Data-with-R-Eliana-Ibrahimi.pdf


### TIDY DATA ###

##Load metadata to perform statistics
metapreg <- data.frame(read_csv("merged_metadata.csv"))
#flip rows and columns
pdf3 = t(pregnant_df_2)
#make Sample.ID's match bt metadata and experimental data
row.names(pdf3) <- metapreg$MBI.Sample.ID

##make it a dataframe
pdf3 <- as.data.frame(pdf3)
#make first column a variable column
pdf3 <- tibble::rownames_to_column(pdf3, "MBI.Sample.ID")
##merge metadata
pdf4 <- full_join(pdf3, metapreg, by = "MBI.Sample.ID")
## make first column the rowname header
pdf5 <- data.frame(pdf4[,-1], row.names=pdf4[,1])

## subset cases and controls
cases <- subset(pdf5, pdf5$Group=="Case")
cases<- cases[c(1:1887)]
controls <- subset(pdf5, pdf5$Group=="Control")
controls <- controls[c(1:1887)]

### NORMALITY CHECKS ####

##perform normality check on controls
contnorm <- lapply(seq_along(controls), function(i){
  shapiro.test(controls[[i]])
})

## subset p values
pvals <- sapply(contnorm, '[[', 'p.value')
## append p-values to dataframe
controls <- rbind(controls, pvals)
row.names(controls)[20]<-"p-values"
##clean up row names
colnames(controls) <- colnames(pdf4)[2:1887]
## sort columns by descending p-values
controls <- controls[,order(controls[nrow(controls),])]

##perform normality check on cases
casenorm <- lapply(seq_along(cases), function(i){
  shapiro.test(cases[[i]])
})

## subset p values
pvals <- sapply(casenorm, '[[', 'p.value')
## append p-values to dataframe
cases <- rbind(cases, pvals)
row.names(cases)[31]<-"p-values"
##clean up row names
colnames(cases) <- colnames(pdf4)[2:1887]
## sort columns by descending p-values
cases <- cases[,order(cases[nrow(cases),])]

#subset non-normally distributed cases
nonormcontrols <- controls[colSums(controls < 0.5) > 0]
nonormcases <- cases[colSums(cases < 0.5) > 0]

### SIGNIFICANCE CHECKS ###

## perform t-test bt normal cases and controls for each pathway

## perform wilcox test bt nonnormal cases and controls for each pathway
tests_list <- lapply(seq_along(controls), function(i){
  wilcox.test(cases[[i]], controls[[i]])
})
## subset p values
pvals <- sapply(tests_list, '[[', 'p.value')
##use older dataframe to merge pvals for sorting
pdf6 <- data.frame(pdf3[,-1], row.names=pdf3[,1])
## append p-values to dataframe
pdf6 <- rbind(pdf6, pvals)
row.names(pdf6)[50]<-"p-values"
##clean up row names
colnames(pdf6) <- colnames(pdf4)[2:1887]
## sort columns by descending p-values
pdfsignif <- pdf6[,order(pdf6[nrow(pdf6),])]
## pull out significant pathway names
pdfsigpaths <- pdfsignif[, pdfsignif[50, ] < 0.05]

#Restructure data
pdf7 <- head(pdfsigpaths, -1)
pdf7 <- pdf7[, -795]
pdf7 <- tibble::rownames_to_column(pdf7, "MBI.Sample.ID")
pdf8 <- full_join(pdf7, metapreg, by = "MBI.Sample.ID")

casesdf <- subset(pdf8, pdf8$Group=="Case")
casesdf <- casesdf[c(1:195)]
contdf <- subset(pdf8, pdf8$Group=="Control")
contdf <- contdf[c(1:195)]

write.csv(pdf8, "pregnant_full_data_2.csv")
write.csv(pdf7, "pregnant_data_2.csv")
write.csv(casesdf, "case_2.csv")
write.csv(contdf, "conts_2.csv")

##Ref. 4: https://www.frontiersin.org/articles/10.3389/fams.2022.884810/full#B19
##Ref. 5: https://bioconductor.org/packages/release/bioc/vignettes/edgeR/inst/doc/edgeRUsersGuide.pdf
##Ref. 6: https://uofabioinformaticshub.github.io/DataVisualisaton_BIS2016/DataVisualisation.html
##Ref. 7: https://stackoverflow.com/questions/73096100/apply-t-test-over-all-columns-of-data-frame-seperated-by-variable
##Ref. 8: https://stackoverflow.com/questions/68720318/how-would-i-run-a-t-test-on-58-variables-columns-to-compare-2-different-data-f