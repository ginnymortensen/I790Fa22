#Genevieve Mortensen for I790 modified 02/01/2022

### MICROBIOME PROFILE OF PREGNANT PEOPLE ###

# Taxonomic Profiling #

##load libraries
library(readr)
library(heatmaply)
library(ggplot2)
library(edgeR)

##Set working directory
#setwd("home/gamorten/prj/pergnancy/humann_work/")
setwd("C:/Users/genev/OneDrive - Indiana University/Projects/I790-Fa22")

##Retrieve data, save as dataframe
pregnant_vector <- data.frame(read_tsv('pregnancy_combined.integrated-pwz-red.tsv'))
pregnant_df <- data.frame(pregnant_vector[,-1], row.names=pregnant_vector[,1])

##Go through each row and determine if a value is zero
row_sub = apply(pregnant_df, 1, function(row) all(row !=0 ))
##Subset as new dataframe
pregnant_df_2 <- pregnant_df[row_sub,]
##Declare matrix
pregnant_mtx <- as.matrix(pregnant_df_2)
##Create heatmap
heatmaply(pregnant_mtx, 
          fontsize_col = 2,
          fontsize_row = 2,
          show_dendrogram = c(FALSE, FALSE),
          main = "Interactive Heatmap",
          xlab = "Sample",
          ylab = "Pathway",
          file = "pregnancy_pathabund_heatmap.html")

##Ref. 1: https://microbiome.github.io/tutorials/all.html
##Ref. 2: https://www.nicholas-ollberding.com/post/introduction-to-the-statistical-analysis-of-microbiome-data-in-r/
##Ref. 3: https://www.ml4microbiome.eu/wp-content/uploads/2021/11/Statistical-Analysis-of-Microbiome-Data-with-R-Eliana-Ibrahimi.pdf


##Load metadata to perform statistics
metapreg <- data.frame(read_csv("pregnant-metadata.csv"))
#subset subject ID's to group by individual
subject_group <- c(metapreg$Subject.ID)

#create edgeR DGE list object to utilize edgeR glm likelihood tests
yedge = DGEList(counts = pregnant_mtx, group = subject_group)

#filter out lowly expressed genes
keep_babies <- filterByExpr(yedge, group = subject_group)
yedge <- yedge[keep_babies,,keep.lib.sizes=FALSE]

#normalize counts
yedge$samples


# ** Not sure ** ?model fit by subject groupings
design <- model.matrix(~subject_group)
yedge <- estimateDisp(yedge,design)
fit <- glmFit(yedge,design)
qlf <- glmQLFTest(fit,coef=2)
topTags(qlf)
fit <- glmFit(yedge,design)
lrt <- glmLRT(fit)
topTags(lrt)

summary(decideTests(lrt))
#visualize results
plotMD(lrt)

##Ref. 4: https://bioconductor.org/packages/release/bioc/vignettes/edgeR/inst/doc/edgeRUsersGuide.pdf