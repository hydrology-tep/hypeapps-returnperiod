#!/opt/anaconda/bin/Rscript --vanilla --slave --quiet
#
# /hypeapps-returnperiod/src/main/app-resources/node_returnperiod/run.R

# Copyright 2017 SMHI
#
# This file is part of H-TEP Hydrological Modelling Application, which is open source 
# and distributed under the terms of the Lesser GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your option) 
# any later version. The Hydrology TEP Hydrological Modelling Application is distributed 
# in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the Lesser GNU 
# General Public License for more details. You should have received a copy of the Lesser 
# GNU General Public License along with the Hydrology TEP Hydrological Modelling Application. 
# If not, see <http://www.gnu.org/licenses/>.

# Application 4: "Return Period Analysis" (hypeapps-returnperiod)
# Author:         David Gustafsson, SMHI
# Version:        2017-10-03

#################################################################################
## 1 - Initialization
## ------------------------------------------------------------------------------
## set application name
app.name = "returnperiod"
## ------------------------------------------------------------------------------
## flag which environment is used, if not set
if(!exists("app.sys")){
  app.sys ="tep"
}

## ------------------------------------------------------------------------------
## load rciop package and set working directory to TMPDIR when running on TEP 
if(app.sys=="tep"){
  library("rciop")
  
  rciop.log ("DEBUG", " *** hypeapps-returnperiod *** TEP hydrological modelling applications ***", "/node_eodata/run.R")
  rciop.log ("DEBUG", " rciop library loaded", "/node_returnperiod/run.R")
  
  setwd(TMPDIR)
  rciop.log("DEBUG", paste(" R session working directory set to ",TMPDIR,sep=""), "/node_returnperiod/run.R")
}

## ------------------------------------------------------------------------------
## load the R hypeapps-environment and hypeapps-utils
if(app.sys=="tep"){
  source(paste(Sys.getenv("_CIOP_APPLICATION_PATH"), "util/R/hypeapps-environment.R",sep="/"))
  source(paste(Sys.getenv("_CIOP_APPLICATION_PATH"), "util/R/hypeapps-utils.R", sep="/"))
  rciop.log ("DEBUG", paste(" libraries loaded and utilities sourced"), "/node_returnperiod/run.R")
}else if(app.sys=="win"){
  source("application/util/R/hypeapps-environment.R")  
  source("application/util/R/hypeapps-utils.R")
}
#################################################################################
## 2 - Application user inputs
## ------------------------------------------------------------------------------
## application input parameters
app.input <- getHypeAppInput(appName = app.name)

if(app.sys=="tep"){rciop.log ("DEBUG", paste("...hypeapps-returnperiod input parameters read"), "/node_returnperiod/run.R")}

#################################################################################
## 3 - Application setup
## -------------------------------------------------------------------------------
## prepare working directories and copy necessary model files
app.setup <- getHypeAppSetup(modelName = model.name,
                             modelBin  = model.bin,
                             tmpDir    = app.tmp_path,
                             appDir    = app.app_path,
                             appName   = app.name,
                             appInput  = app.input,
                             modelFilesURL = model.files.url)

if(app.sys=="tep"){rciop.log ("DEBUG", paste("...hypeapps-returnperiod setup prepared"), "/node_returnperiod/run.R")}

#################################################################################
## 4 - Download timeOutput data (COUT, CPRC, CTMP, CRUN, ...)
## -------------------------------------------------------------------------------
## get timeOutput data from catalogue
timeOutput.data <- getTimeOutputData(appInput = app.input,
                                     appSetup = app.setup)
if(app.sys=="tep"){rciop.log ("DEBUG", paste("timeOutput data downloaded from catalogue"), "/node_returnperiod/run.R")}

#################################################################################
## 5 - Return Period Magnitude Analysis
## -------------------------------------------------------------------------------
## Analyse the timeOutput data with ReturnPeriodMagnitude function
#if(app.sys=="tep"){
#  rciop.publish(path=paste(timeOutput.data$timeFile[1],"",sep=""), recursive=FALSE, metalink=TRUE)
#}
app.output <- analyseTimeOutputData(appSetup = app.setup,appInput = app.input,
                                    timeData = timeOutput.data)

if(app.sys=="tep"){rciop.log ("DEBUG", paste("TimeOutputData analysed and return level files written to output"), "/node_returnperiod/run.R")}


## ------------------------------------------------------------------------------
## publish postprocessed results
if(app.sys=="tep"){
  rciop.publish(path=paste(app.output$outDir,"/*",sep=""), recursive=FALSE, metalink=TRUE)
}

## ------------------------------------------------------------------------------
## exit with appropriate status code
q(save="no", status = 0)
