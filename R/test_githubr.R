## Methods for running the unit tests suite
#####


.unitTests <- function(dir=system.file("unitTests", package="githubr"), testFileRegexp = "^test_.*\\.R$") {
  .runTestSuite(dir=dir, testFileRegexp=testFileRegexp, testFuncRegexp="^unitTest.+", suiteName="unit tests")
}

.integrationTests <- function(dir=system.file("integrationTests", package="githubr"), testFileRegexp="^test_.*\\.R$"){
  .runTestSuite(dir=dir, testFileRegexp=testFileRegexp, testFuncRegexp="^integrationTest.+", suiteName="integration tests")
}

.runTestSuite <- function(dir, testFileRegexp, testFuncRegexp, suiteName){
  
  .failure_details <- function(result) {
    res <- result[[1L]]
    if (res$nFail > 0 || res$nErr > 0) {
      Filter(function(x) length(x) > 0,
             lapply(res$sourceFileResults,
                    function(fileRes) {
                      names(Filter(function(x) x$kind != "success",
                                   fileRes))
                    }))
    } else list()
  }
  
  require("RUnit", quietly=TRUE) || stop("RUnit package not found")
  RUnit_opts <- getOption("RUnit", list())
#   if(githubr:::.getCache("debug")) {
#     RUnit_opts$verbose <- 10L
#     RUnit_opts$silent <- FALSE
#   } else {
#     RUnit_opts$verbose <- 0L
#     RUnit_opts$silent <- TRUE
#   }
  RUnit_opts$verbose_fail_msg <- TRUE
  options(RUnit = RUnit_opts)
  suite <- defineTestSuite(name=paste("githubr RUnit Test Suite", suiteName),
                           dirs=dir,
                           testFileRegexp=testFileRegexp,
                           testFuncRegexp=testFuncRegexp,
                           rngKind="default",
                           rngNormalKind="default")
  result <- runTestSuite(suite)
  cat("\n\n")
  printTextProtocol(result, showDetails=FALSE)
  if (length(details <- .failure_details(result)) >0) {
    cat("\nTest files with failing tests\n")
    for (i in seq_along(details)) {
      cat("\n  ", basename(names(details)[[i]]), "\n")
      for (j in seq_along(details[[i]])) {
        cat("    ", details[[i]][[j]], "\n")
      }
    }
    cat("\n\n")
    stop(paste(suiteName, " tests failed for package githubr"))
  }
  result
}
