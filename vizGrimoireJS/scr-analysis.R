## Copyright (C) 2012, 2013 Bitergia
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
##
## This file is a part of the vizGrimoire.R package
## http://vizgrimoire.bitergia.org/
##
## Analyze and extract metrics data gathered by Bicho tool
## http://metricsgrimoire.github.com/Bicho
##
## Authors:
##   Daniel Izquierdo Cortazar <dizquierdo@bitergia.com>
##   Alvaro del Castillo <acs@bitergia.com>
##
##
## Usage:
##  R --vanilla --args -d dbname < scr-analysis.R
## or
##  R CMD BATCH scm-analysis.R
##

library("vizgrimoire")
library("ISOweek")
options(stringsAsFactors = FALSE) # avoid merge factors for toJSON 



conf <- ConfFromOptParse()
SetDBChannel (database = conf$database, user = conf$dbuser, password = conf$dbpassword)

if (conf$granularity == 'years') { 
    period = 'year'
    nperiod = 365
} else if (conf$granularity == 'months') { 
    period = 'month'
    nperiod = 31
} else if (conf$granularity == 'weeks') { 
    period = 'week'
    nperiod = 7
} else if (conf$granularity == 'days'){ 
    period = 'day'
    nperiod = 1
} else {stop(paste("Incorrect period:",conf$granularity))}

# destination directory
destdir <- conf$destination
#type of analysis
reports=strsplit(conf$reports,",",fixed=TRUE)[[1]]


# BOTS filtered
# WARNING: info specific for the wikimedia case, this should be removed for other communities
#          or in the case that bots are required to be in the analysis
bots = c('wikibugs','gerrit-wm','wikibugs_','wm-bot','','Translation updater bot','jenkins-bot')

#########
#EVOLUTIONARY DATA
########

print ("ANALYSIS PER TYPE OF REVIEW")
reviews.evol = NA
#Reviews info
data = EvolReviewsSubmitted(period, conf$startdate, conf$enddate)
reviews.evol <- completePeriodIds(data, conf$granularity, conf)
data = EvolReviewsOpened(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
data = EvolReviewsNew(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
data = EvolReviewsInProgress(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
data = EvolReviewsClosed(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
data = EvolReviewsMerged(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
data = EvolReviewsAbandoned(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
# print(reviews.evol)
#Patches info
data = EvolPatchesVerified(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
data = EvolPatchesApproved(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
data = EvolPatchesCodeReview(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
data = EvolPatchesSent(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
# print(reviews.evol)
#Waiting for actions info
data = EvolWaiting4Reviewer(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
data = EvolWaiting4Submitter(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
# print(reviews.evol)
#Reviewers info
data = EvolReviewers(period, conf$startdate, conf$enddate)
reviews.evol = merge(reviews.evol, completePeriodIds(data, conf$granularity, conf), all=TRUE)
# print(reviews.evol)
createJSON(reviews.evol, paste(destdir,"/scr-evolutionary.json", sep=''))


#########
#STATIC DATA
#########

reviews.static = NA
#Reviews info
reviews.static = StaticReviewsSubmitted(period, conf$startdate, conf$enddate)
reviews.static = merge(reviews.static, StaticReviewsOpened(period, conf$startdate, conf$enddate))
reviews.static = merge(reviews.static, StaticReviewsNew(period, conf$startdate, conf$enddate))
reviews.static = merge(reviews.static, StaticReviewsInProgress(period, conf$startdate, conf$enddate))
reviews.static = merge(reviews.static, StaticReviewsClosed(period, conf$startdate, conf$enddate))
reviews.static = merge(reviews.static, StaticReviewsMerged(period, conf$startdate, conf$enddate))
reviews.static = merge(reviews.static, StaticReviewsAbandoned(period, conf$startdate, conf$enddate))
# print(reviews.static)
#Patches info
reviews.static = merge(reviews.static, StaticPatchesVerified(period, conf$startdate, conf$enddate))
reviews.static = merge(reviews.static, StaticPatchesApproved(period, conf$startdate, conf$enddate))
reviews.static = merge(reviews.static, StaticPatchesCodeReview(period, conf$startdate, conf$enddate))
reviews.static = merge(reviews.static, StaticPatchesSent(period, conf$startdate, conf$enddate))
# print(reviews.static)
#Waiting for actions info
reviews.static = merge(reviews.static, StaticWaiting4Reviewer(period, conf$startdate, conf$enddate))
reviews.static = merge(reviews.static, StaticWaiting4Submitter(period, conf$startdate, conf$enddate))
# print(reviews.static)
#Reviewers info
reviews.static = merge(reviews.static, StaticReviewers(period, conf$startdate, conf$enddate))
# print(reviews.static)
createJSON(reviews.static, paste(destdir,"/scr-static.json", sep=''))

########
#ANALYSIS PER REPOSITORY
########

print("ANALYSIS PER REPOSITORY BASIC")
if ('repositories' %in% reports) {
    # repos  <- GetReposSCRName(conf$startdate, conf$enddate, 30)
    repos  <- GetReposSCRName(conf$startdate, conf$enddate)
    repos <- repos$name
    repos_file_names = gsub("/","_",repos)
    createJSON(repos_file_names, paste(destdir,"/scr-repos.json", sep=''))

    # missing information from the rest of type of reviews, patches and
    # number of patches waiting for reviewer and submitter 
    for (repo in repos) {
        print (repo)
        repo_file = gsub("/","_",repo)
        type_analysis = list('repository', repo)
        # Evol
        submitted <- EvolReviewsSubmitted(period, conf$startdate, conf$enddate, type_analysis)
        submitted <- completePeriodIds(submitted, conf$granularity, conf)
        merged <- EvolReviewsMerged(period, conf$startdate, conf$enddate, type_analysis)
        merged <- completePeriodIds(merged, conf$granularity, conf)
        abandoned <- EvolReviewsAbandoned(period, conf$startdate, conf$enddate, type_analysis)
        abandoned <- completePeriodIds(abandoned, conf$granularity, conf)
        evol = merge(submitted, merged, all = TRUE)
        evol = merge(evol, abandoned, all = TRUE)
        evol <- completePeriodIds(evol, conf$granularity, conf)
        createJSON(evol, paste(destdir, "/",repo_file,"-scr-evolutionary.json", sep=''))

        # Static
        static <- StaticReviewsSubmitted(period, conf$startdate, conf$enddate, type_analysis)
        static <- merge(static, StaticReviewsMerged(period, conf$startdate, conf$enddate, type_analysis))
        static <- merge(static, StaticReviewsAbandoned(period, conf$startdate, conf$enddate, type_analysis))
        createJSON(static, paste(destdir, "/",repo_file,"-scr-static.json", sep=''))
    }
}

########
#ANALYSIS PER COMPANY
########

print("ANALYSIS PER COMPANY BASIC")
if ('companies' %in% reports) {
    # repos  <- GetReposSCRName(conf$startdate, conf$enddate, 30)
    companies  <- GetCompaniesSCRName(conf$startdate, conf$enddate, conf$identities_db)
    companies <- companies$name
    companies_file_names = gsub("/","_",companies)
    createJSON(companies_file_names, paste(destdir,"/scr-companies.json", sep=''))
    
    # missing information from the rest of type of reviews, patches and
    # number of patches waiting for reviewer and submitter 
    for (company in companies) {
        print(company)
        company_file = gsub("/","_",company)
        type_analysis = list('company', company)
        # Evol
        submitted <- EvolReviewsSubmitted(period, conf$startdate, conf$enddate, type_analysis, conf$identities_db)
        submitted <- completePeriodIds(submitted, conf$granularity, conf)
        merged <- EvolReviewsMerged(period, conf$startdate, conf$enddate, type_analysis, conf$identities_db)
        merged <- completePeriodIds(merged, conf$granularity, conf)
        abandoned <- EvolReviewsAbandoned(period, conf$startdate, conf$enddate, type_analysis, conf$identities_db)
        abandoned <- completePeriodIds(abandoned, conf$granularity, conf)
        evol = merge(submitted, merged, all = TRUE)
        evol = merge(evol, abandoned, all = TRUE)
        evol <- completePeriodIds(evol, conf$granularity, conf)
        createJSON(evol, paste(destdir, "/",company_file,"-scr-evolutionary.json", sep=''))
        # Static
        static <- StaticReviewsSubmitted(period, conf$startdate, conf$enddate, type_analysis, conf$identities_db)
        static <- merge(static, StaticReviewsMerged(period, conf$startdate, conf$enddate, type_analysis, conf$identities_db))
        static <- merge(static, StaticReviewsAbandoned(period, conf$startdate, conf$enddate, type_analysis, conf$identities_db))
        createJSON(static, paste(destdir, "/",company_file,"-scr-static.json", sep=''))
    }
}

########
# PEOPLE
########
if ('people' %in% reports) {
    print("PEOPLE ANALYSIS")
    people = GetPeopleListSCR(conf$startdate, conf$enddate)
    people = people$id
    limit = 60
    if (length(people)<limit) limit = length(people);
    people = people[1:limit]
    createJSON(people, paste(destdir,"/scr-people.json",sep=''))

    for (upeople_id in people){
        evol = GetPeopleEvolSCR(upeople_id, period, conf$startdate, conf$enddate)
        evol <- completePeriodIds(evol, conf$granularity, conf)
        evol[is.na(evol)] <- 0
        createJSON(evol, paste(destdir,"/people-",upeople_id,"-scr-evolutionary.json", sep=''))

        static <- GetPeopleStaticSCR(upeople_id, conf$startdate, conf$enddate)
        createJSON(static, paste(destdir,"/people-",upeople_id,"-scr-static.json", sep=''))
    }
}

# Tops
top_reviewers <- list()
top_reviewers[['reviewers']] <- GetTopReviewersSCR(0, conf$startdate, conf$enddate, conf$identities_db, bots)
top_reviewers[['reviewers.last year']]<- GetTopReviewersSCR(365, conf$startdate, conf$enddate, conf$identities_db, bots)
top_reviewers[['reviewers.last month']]<- GetTopReviewersSCR(31, conf$startdate, conf$enddate, conf$identities_db, bots)

# Top openers
top_openers <- list()
top_openers[['openers.']]<-GetTopOpenersSCR(0, conf$startdate, conf$enddate,conf$identities_db, bots)
top_openers[['openers.last year']]<-GetTopOpenersSCR(365, conf$startdate, conf$enddate,conf$identities_db, bots)
top_openers[['openers.last_month']]<-GetTopOpenersSCR(31, conf$startdate, conf$enddate,conf$identities_db, bots)

# Top mergers
top_mergers <- list()
top_mergers[['mergers.']]<-GetTopMergersSCR(0, conf$startdate, conf$enddate,conf$identities_db, bots)
top_mergers[['mergers.last year']]<-GetTopMergersSCR(365, conf$startdate, conf$enddate,conf$identities_db, bots)
top_mergers[['mergers.last_month']]<-GetTopMergersSCR(31, conf$startdate, conf$enddate,conf$identities_db, bots)

createJSON (c(top_reviewers, top_openers, top_mergers), paste(destdir,"/scr-top.json", sep=''))

