% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/linker_runphaseone.R
\name{LINKER_runPhase1}
\alias{LINKER_runPhase1}
\alias{LINKER_init}
\alias{LINKER_ReassignGenesToClusters}
\alias{LINKER_corrClust}
\alias{LINKER_extract_modules}
\alias{LINKER_EvaluateTestSet}
\alias{LINKER_LearnRegulatoryPrograms}
\title{Phase I : module generation}
\usage{
LINKER_runPhase1(
  lognorm_est_counts,
  target_filtered_idx,
  regulator_filtered_idx,
  nassay = 1,
  regulator = "regulator",
  NrModules,
  Lambda = 5,
  alpha = 1 - 1e-06,
  pmax = 10,
  mode = "VBSR",
  used_method = "MEAN",
  NrCores = 1,
  corrClustNrIter = 100,
  Nr_bootstraps = 1,
  FDR = 0.05,
  only_train = FALSE
)

LINKER_init(
  MA_matrix_Var,
  RegulatorData,
  NrModules,
  NrCores = 3,
  corrClustNrIter = 21,
  Parameters,
  FDR
)

LINKER_ReassignGenesToClusters(
  Data,
  RegulatorData,
  Beta,
  Clusters,
  NrCores = 1
)

LINKER_corrClust(LINKERinit)

LINKER_extract_modules(results)

LINKER_EvaluateTestSet(
  LINKERresults,
  MA_Data_TestSet,
  RegulatorData_TestSet,
  used_method = "MEAN"
)

LINKER_LearnRegulatoryPrograms(
  Data,
  Clusters,
  RegulatorData,
  Lambda,
  alpha,
  pmax,
  mode,
  used_method = "MEAN",
  NrCores = 1,
  FDR
)
}
\arguments{
\item{lognorm_est_counts}{Matrix of log-normalized estimated counts of the gene expression
data (Nr Genes x Nr samples)}

\item{target_filtered_idx}{Index array of the target genes on the lognorm_est_counts matrix if
SummarizedExperiment object is not provided.}

\item{regulator_filtered_idx}{Index array of the regulatory genes on the lognorm_est_counts matrix if
SummarizedExperiment object is not provided.}

\item{nassay}{if SummarizedExperiment object is passed as input to lognorm_est_counts, name of the
assay containing the desired matrix. Default: 1 (first item in assay's list).}

\item{regulator}{if SummarizedExperiment object is passed as input to lognorm_est_counts, name of the
rowData() variable to build target_filtered_idx and regulator_filtered_idx. This variable must be one
for driver genes and zero for target genes. Default: 'regulator'}

\item{NrModules}{Number of modules that are a priori to be found (note that the final number of modules
discovered may differ from this value). By default, 100 modules.}

\item{Lambda}{Lambda variable for Lasso models.}

\item{alpha}{Alpha variable for Lasso models.}

\item{pmax}{Maximum numbers of regulators that we want.}

\item{mode}{Chosen method(s) to link module eigengenes to regulators. The available options are
'VBSR', 'LASSOmin', 'LASSO1se', 'LASSOparam' and 'LM'. Default set to 'VBSR'}

\item{used_method}{Method selected for use. Default set to MEAN.}

\item{NrCores}{Nr of computer cores for the parallel parts of the method. Note that the parallelization
is NOT initialized in any of the functions. By default, 2.}

\item{corrClustNrIter}{Number of iteration for the phase I part of the method.}

\item{Nr_bootstraps}{Number of bootstrap of Phase I. By default, 1.}

\item{FDR}{The False Discovery Rate correction used for the modules and graphs GRN uncovering. By default, 0.05.}

\item{only_train}{whether to use only training samples within LINKER run. Default: FALSE}

\item{MA_matrix_Var}{Matrix of log-normalized estimated counts of the gene expression data, centered and scaled, containing
only the train samples.}

\item{RegulatorData}{Expression matrix containing only the regulators of the train samples.}

\item{Parameters}{List of parameters containig lambda, pmax, alpha, mode and used method.}

\item{Data}{Matrix of log-normalized estimated counts of the gene expression data, centered and scaled, containing
only the train samples.}

\item{Beta}{Coefficient on which the decision of reassigning genes is based.}

\item{Clusters}{Clusters generated from the linkerinit function.}

\item{LINKERinit}{Initialization object obtained from \code{LINKER_init()}.}

\item{results}{Matrix of log-normalized estimated counts of the gene expression data (Nr Genes x Nr samples).}

\item{LINKERresults}{List containing the number of clusters, regulatoryprogram, name of regulators and all genes and module membership.}

\item{MA_Data_TestSet}{Matrix of log-normalized estimated counts of the gene expression data, centered and scaled, containing
only the test samples.}

\item{RegulatorData_TestSet}{Expression matrix containing only the regulators of the test samples.}
}
\value{
igraph object containing the modules containing the related drivers and targets within bootstraps.
}
\description{
Run first phase of the linker method where K modules of similarly expressed target genes and
relate them to a linear combination of very few regulators, according to the selected model. \code{LINKER_init()}
evaluate kmeans on a train set to generate a initial set of clusters containing drivers and target genes.
\code{LINKER_ReassignGenesToClusters()} reassigning genes based on closed match to new regulatory programs.
This functions takes place inside the linkerrun function, so it is not recommended to run it on its own.
\code{LINKER_corrClust()} go through two steps within a loop, learning regulatory program of modules and reassigning
genes. \code{LINKER_extract_modules()} extract all the modules, genes and relevant information. \code{LINKER_EvaluateTestSet()}
fits the selected model with the test data. \code{LINKER_LearnRegulatoryPrograms()} learns the regulatory program of the modules.
}
\examples{

   ## This example is very similar to the `LINKER_run()` function.
   ## Again, we are going to join drivers and targets genes to create the working dataset.

   drivers <- readRDS(paste0(system.file('extdata',package='TraRe'),'/tfs_linker_example.rds'))
   targets <- readRDS(paste0(system.file('extdata',package='TraRe'),'/targets_linker_example.rds'))

   lognorm_est_counts <- rbind(drivers,targets)
   ## We create the index for drivers and targets in the log-normalized gene expression matrix.

   R<-60
   T<-200

   regulator_filtered_idx <- seq_len(R)
   target_filtered_idx <- R+c(seq_len(T))

   ## We recommend to use the default values of the function.
   ## For the sake of time, we will select faster (and worse) ones.

   linkeroutput <- LINKER_runPhase1(lognorm_est_counts,target_filtered_idx=target_filtered_idx,
                                    regulator_filtered_idx=regulator_filtered_idx, NrModules=2,
                                    mode='LASSOmin',NrCores=2, corrClustNrIter=10,Nr_bootstraps=1)

}
