######################################################################
##These need to be uncommented to really run but are commented for testing
##purposes - i'd like to run this on the internet but have no access
#incomegrid <- seq(0,500000,by=25000)
#longtermcapitalgainsgrid <- c(0,100,1000,10000,seq(100000,5100001,by=1000000))
##dividendincomegrid <- seq(0,5000000,by=1000000)
#socialsecuritygrid <- seq(0,40000,by=8000)
incomegrid <- seq(0,500000,by=25000)
longtermcapitalgainsgrid <- seq(0,400000,by=25000)
socialsecuritygrid <- seq(0,40000,by=8000)
######################################################################

#Object definitions: (still incomplete)
#finances
#- 
#decisions
#-T1 - the retirement period
#-laborincome - the income received over the working life
#-retirementIncomeGoal - the 2011 dollar value of consumption for each year
#of retirment.  In general there is no check on decision feasibility outside
#of the program logic, so this could be trillions of dollars or more per
#year.
#-savingsRate - The fraction of labor income saved every year
#- In general, I would add taxsim decision parameters in here as well.  None are
#currently supported, but things like children, marital status, and state of
#residence should go in here - this way you could call pension(decisions)
#for a range of decisions and then compare the outcomes
#-ssType
#parameters
#-IRAlimit
#-

inv <- function(value,vec){
    #This code takes value and returns the index of the largest element of
    #vec (a sorted vector) that value is greater than.  It can be called
    #with vapply as in indexvalue.  If the function 'vec' is not monotonic,
    #there could be significant issues
    a<-floor(value/(vec[2]-vec[1])) + 1
    a[a < 1] <- 1
    a[a > length(vec)] <- length(vec)
    return(a)
    #print(a)
    #print(vec[a])
    return(vec[a])
    return(approx(vec,seq(1,length(vec)),xout=value,method="constant",rule=2)$y)
}

indexvalue <- function(aval,bval,dval,agrid, bgrid, dgrid, func ){
    #this function takes 3 function values and returns the indexes that
    #would need to be used to look up the three dimensional function value.
    #So there's a function f(aval,bval,cval) that is represented by some
    #discreete points a1...an, b1...bn, and c1...cn, and we want to know
    #f(aval, bval, cval), but we really need to know the index ai, bi, ci, 
    #which would best approximate f(aval, bval, cval).  
    # I would like to extend the function to take 3 equal length vectors
    # and one array representign f(a,b,c) and return a vector that is the
    # value of f for these vectors.
    #acall <- inv(aval,agrid)
    #bcall <- inv(bval,bgrid)
    #dcall <- inv(dval,dgrid)
    acall <- floor(aval/(agrid[2]-agrid[1]))+1
    bcall <- floor(bval/(bgrid[2]-bgrid[1]))+1
    dcall <- floor(dval/(dgrid[2]-dgrid[1]))+1
    acall[acall < 1] <- 1
    acall[acall > length(agrid)] <- length(agrid)
    bcall[bcall < 1] <- 1
    bcall[bcall > length(bgrid)] <- length(bgrid)
    dcall[dcall < 1] <- 1
    dcall[dcall > length(dgrid)] <- length(dgrid)
    #print(cbind(acall,aval,bcall,bval,dcall,dval))
    output <- array(func,dim=c(length(agrid),length(bgrid),length(dgrid)))
    #The key insight here is expand.grid(a1,a2,a3) to
    #array(.,dim=c(a1,a2,a3)) is what orders things into a 3d array
    #return(list(output=output,val=output[acall$key,bcall$key,dcall$key]))
    #Used to have key and value returned from inv, and this worked
    #return(list(output=output,val=output[cbind(acall,bcall,dcall)]))
    return(output[cbind(acall,bcall,dcall)])
}

taxlookup <-
    function(taxinfo=NULL, ftp=FALSE, tsindex=4, taxtable=taxsim){
    #function(income=100000, over65=0, longtermcapitalgains=0,
             #dividendincome=0, dependents=0, married=0,
             #socialsecurityincome=0, state=9, year=2011, spouseincome=0,
             #propertyincome=0, taxablepensions=0, transferincome=0,
             #rentpaid=0, realestatepaid=0, itemizeddeductions=0,
             #childcareexpense=0, uiincome=0, nonAMTdeductions=0,
             #shorttermcapgains=0, ftp=FALSE, tsindex=4, taxtable=taxsim){
        #Keep this old argument list, which fills in blanks for calls
        # Currently I actually couldn't use all these arguments.  I could
        # pass them to get a taxsim file, but I'm not confident that I
        # could then lookup results based on the other values.
        # tsindex is a variable that takes integer values that represent
        # which column of the taxsim output should be used to look up
        if (ftp) {
            library('RCurl')
            #print(taxinfo$income)
            #print(taxinfo$longtermcapitalgains)
            url<-paste('ftp://taxsim:02138@taxsimftp.nber.org/tmp/',format(Sys.time(),"%Y%m%d%H%M%S"),sep='')
            outputurl<-paste(url,'taxsim',sep='.')
            msgurl<-paste(url,'msg',sep='.')
            big<-expand.grid(taxinfo$income,
                             taxinfo$over65,taxinfo$longtermcapitalgains,taxinfo$dividendincome,taxinfo$dependents)
            #print(dim(big))
            tsfile <-
                cbind(seq(1,dim(big)[1]),taxinfo$year,taxinfo$state,taxinfo$married,
                      taxinfo$dependents,big$Var2,big$Var1,
                      taxinfo$spouseincome,big$Var4,taxinfo$propertyincome,
                      taxinfo$taxablepensions,taxinfo$socialsecurityincome,taxinfo$transferincome,
                      taxinfo$rentpaid,taxinfo$realestatepaid,taxinfo$itemizeddeductions,
                      taxinfo$childcareexpense,taxinfo$uiincome,big$Var5,
                      taxinfo$nonAMTdeductions,taxinfo$shorttermcapgains,big$Var3)
            temp<- file('test.txt')
            headline<-"9 11 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 "
            write(headline,temp,append=FALSE) 
            system('cat test.txt')
            #writeLines(headline, con=temp)
            temptable<- file('testtable.txt')
            write.table(tsfile, temptable, row.names=FALSE, col.names=FALSE, append=TRUE)
            system('cat testtable.txt >> test.txt')
            ftpUpload('test.txt',url)
            names<-c('Case ID','Year','State','Federal income tax liability','State income tax liability','FICA (OADSI and HI, employee AND employer)','federal marginal rate on wage income','state marginal rate on wage income','FICA rate','Federal AGI','UI in AGI','Social Security in AGI','Zero Bracket Amount','Personal Exemptions','Exemption Phaseout','Deduction Phaseout','Deductions Allowed (Zero for non-itemizers)','Federal Taxable Income','Federal Regular Tax','Exemption Surtax','General Tax Credit','Child Tax Credit (as adjusted)','Additional Child Tax Credit (refundable)','Child Care Credit','Earned Income Credit','Income for the Alternative Minimum Tax','AMT Liability (addition to regular tax)','Federal Income Tax Before Credits','FICA','State Household Income','State Rent Payments','State AGI','State Exemption amount','State Standard Deduction','State Itemized Deductions','State Taxable Income','State Property Tax Credit','State Child Care Credit','State EIC','State Total Credits','State Bracket Rate')
            taxsim <- read.table(textConnection(getURL(outputurl)))
            names(taxsim)<-names
            save(tsfile,taxsim,file="taxsim.RData")
        }
        #load('taxsim.RData')
        a <- taxinfo$income
        b <- taxinfo$longtermcapitalgains
        d <- taxinfo$socialsecurityincome
        #print(length(d))
        #print(d)
        tax <- indexvalue(aval=a, bval=b, dval=d, agrid=incomegrid,
                          bgrid=longtermcapitalgainsgrid,
                          dgrid=socialsecuritygrid,
                          func=as.matrix(taxtable[tsindex],1))
        #this calculates the federal tax from taxsim.  The key thing is
        #that the taxsim results have to be in matrix form.  Without
        #that, indexing doesn't work right.
        #print(cbind(a,b,d))
        return(tax)
}

taxes <- function(income=100000, over65=0, longtermcapitalgains=0,
                  dividendincome=0, dependents=0, married=0,
                  socialsecurityincome=0, state=9, year=2011,
                  spouseincome=0, propertyincome=0, taxablepensions=0,
                  transferincome=0, rentpaid=0, realestatepaid=0,
                  itemizeddeductions=0, childcareexpense=0, uiincome=0,
                  nonAMTdeductions=0, shorttermcapgains=0){
    taxinfo <- NULL
    taxinfo$income <- income
    taxinfo$over65 <- over65
    taxinfo$longtermcapitalgains <- longtermcapitalgains
    taxinfo$dividendincome <- dividendincome
    taxinfo$dependents <- dependents
    taxinfo$married <- married
    taxinfo$socialsecurityincome <- socialsecurityincome
    taxinfo$state <- state
    taxinfo$year <- year
    taxinfo$spouseincome <- spouseincome
    taxinfo$propertyincome <- propertyincome
    taxinfo$taxablepensions <- taxablepensions
    taxinfo$transferincome <- transferincome
    taxinfo$rentpaid <- rentpaid
    taxinfo$realestatepaid <- realestatepaid
    taxinfo$itemizeddeductions <- itemizeddeductions
    taxinfo$childcareexpense <- childcareexpense
    taxinfo$uiincome <- uiincome
    taxinfo$nonAMTdeductions <- nonAMTdeductions
    taxinfo$shorttermcapgains <- shorttermcapgains
    #print(socialsecurityincome)
    #print(length(taxinfo$income))
    #print(length(taxinfo$income))

    #print(taxinfo)
    #print(head(taxsim))
    fed <- taxlookup(taxinfo=taxinfo, tsindex=5, ftp=FALSE, taxtable=taxsim)
    fedrate <- taxlookup(taxinfo=taxinfo, tsindex=7, ftp=FALSE, taxtable=taxsim)
    #print(length(fedrate))
    state <- taxlookup(taxinfo=taxinfo, tsindex=4, ftp=FALSE, taxtable=taxsim)
    staterate <- taxlookup(taxinfo=taxinfo, tsindex=8, ftp=FALSE, taxtable=taxsim)
    fica <- taxlookup(taxinfo=taxinfo, tsindex=29, ftp=FALSE, taxtable=taxsim)
    ficarate <- taxlookup(taxinfo=taxinfo, tsindex=9, ftp=FALSE, taxtable=taxsim)

    fedcaprate <- taxlookup(taxinfo=taxinfo, tsindex=7, ftp=FALSE, taxtable=taxsimcapitalgains)
    #print(fedcaprate)
    statecaprate <- taxlookup(taxinfo=taxinfo, tsindex=8, ftp=FALSE, taxtable=taxsimcapitalgains)
    fedagi <- taxlookup(taxinfo=taxinfo, tsindex=10, ftp=FALSE, taxtable=taxsim)
    taxsimIncome <- incomegrid[inv(income,incomegrid)]
    taxsimCapitalGains <- longtermcapitalgainsgrid[inv(longtermcapitalgains,longtermcapitalgainsgrid)]
    #taxsimSocialSecurity <- socialsecuritygrid[inv(socialsecurityincome,socialsecuritygrid)]
    #taxsimIncome <- incomegrid[sapply(X=income,FUN=inv,incomegrid)]
    #taxsimCapitalGains <- longtermcapitalgainsgrid[sapply(X=longtermcapitalgains,FUN=inv,longtermcapitalgainsgrid)]
    margrate <- ficarate + fedrate + staterate
    caprate <- fedcaprate + statecaprate
    alltax <- state + fed + fica
    tax <- alltax + (income - taxsimIncome) * margrate / 100 + (longtermcapitalgains - taxsimCapitalGains) * caprate / 100 
    #print(cbind(income,tax,margrate,caprate,alltax,fedagi,socialsecurityincome))
    #print(socialsecurityincome)
    #print('capital gains level and rate')
    #print(cbind(income, longtermcapitalgains, fedcaprate, margrate,
                #statecaprate,alltax,taxsimIncome,taxsimCapitalGains))
    #print(cbind(taxsimIncome,taxsimCapitalGains))
    return(list(tax=tax,rate=margrate, caprate=caprate))
}

earlyfactor <- function(decisions,parameters){
    # Thsi function takes a person's birthday and retirement date and
    # returns the social security multiplier that determines how much
    # higher or lower the monthly benefit payment will be
    today <- Sys.Date()
    now <- as.numeric(format(today,"%Y"))
    myage <- floor(as.double(today-parameters$birthday)/365.25)
    birthyear <- as.numeric(format(parameters$birthday,"%Y"))
    if (birthyear < 1938)  normalretirementdate <- parameters$birthday + 65*365.25 
    if (birthyear >= 1938 & birthyear < 1943) normalretirementdate <-
        parameters$birthday + 65*365.25 +365.35 * (birthyear - 1937)/6
    if (birthyear >= 1943 & birthyear < 1955) normalretirementdate <-
        parameters$birthday + 66*365.25
    if (birthyear >= 1955 & birthyear < 1961) normalretirementdate <-
        parameters$birthday + 66*365.25 +365.35 * (birthyear - 1954)/6
    if (birthyear > 1960) normalretirementdate <- parameters$birthday + 67*365.25
    as.numeric(format(normalretirementdate,"%Y"))-birthyear
    lateprice <- min(.08,.03+ceiling((birthyear - 1924)/2)*.005)
    retirementadjustmentmonths <- as.numeric(min(decisions$retirementDate,parameters$birthday + 70*365.25)-normalretirementdate)/(365.25/12)
    if (retirementadjustmentmonths < 0){
        retirementadjustmentmonths <- ceiling(retirementadjustmentmonths) 
        if (retirementadjustmentmonths < -36) retfactor <- .8+max(5/1200*(retirementadjustmentmonths-36),-.1)
        if (retirementadjustmentmonths >= -36) retfactor  <- 1+5/900*retirementadjustmentmonths
    }
    if (retirementadjustmentmonths >= 0){
        retirementadjustmentmonths  <-  floor(retirementadjustmentmonths)
        retfactor <- 1+lateprice/12*retirementadjustmentmonths
    }
    return(retfactor)
}

funevals <- 0
remaining <- function(retirementIncomeGuess, decisions,parameters){
    decisions$retirementIncomeGoal <- retirementIncomeGuess
    #print('called remaining with income goal:')
    #print(decisions$retirementIncomeGoal)
    #This functino calculates how much money you would be left with if
    #you had given income levels and then spent at retirementIncomeGoal
    #real levels durign retirement
    finances <- calcFinance(decisions,parameters)
    #print(finances$savings[decisions$T2-1])
    #print('remaining value is:')
    #print(finances$savings[parameters$T2])
    return(sum((finances$savings[parameters$T2]-decisions$estate*((1+parameters$inflation)^(parameters$T2)))^2))
}

calcFinance <- function(decisions, parameters){
    #This function calculates savings, income, and consumption paths for
    #a given level of retirement consumption.  It also calculates taxes.
    #It returns a 'finances' structure with many elements set.  There is no
    #check to make sure this returns  'feasible' finances.
    #print(finances)
    #print(parameters$savingsRate)
    t <- parameters$t
    T1 <- decisions$T1
    T2 <- parameters$T2
    inflation <- parameters$inflation
    initialIncome <- parameters$initialIncome
    finances <- NULL
    finances$laborincome <- parameters$potentialLaborIncome * (t < T1)
    finances$currentSavings <- finances$laborincome * decisions$savingsRate
    #print(parameters$IRAlimit)
    #print(parameters$currentSavings)
    finances$toIRA <- pmin(finances$currentSavings,parameters$IRAlimit)
    #finances$taxableincome <- finances$laborincome - finances$toIRA
    #finances$deductions <- finances$toIRA 
    finances$retirementConsumptionPath <- ((1+parameters$inflation)^t) * (t >=T1)
    finances$returnHistory <- parameters$returnHistory
    finances$retirementIncome <- decisions$retirementIncomeGoal
    finances$capitalgains <- rep(0,T2)
    finances$capitalgainsrate <- rep(0,T2)
    #print(finances$socialsecurity)
    #print(finances$taxes)
    #print(length(finances$taxes$caprate))
    #print(length(finances$taxes$rate))
    #print(length(finances$taxes$tax))
    finances$taxes$tax <- finances$taxes$tax * ((1+parameters$inflation)^(t))
    finances$netincome <- finances$laborincome - finances$taxes$tax + finances$capitalgains
    finances$socialsecurity <- calcSS(decisions,parameters,finances)
    #Note that calcSS takes a PARTIALLY COMPLETED finances object - this
    #could cause problems at some point
    finances$taxes <- #Deflate income variables to current dollar values, then reinflate
        taxes(income=finances$laborincome *
              ((1+parameters$inflation)^(-t)),
              longtermcapitalgains=finances$capitalgains * ((1+parameters$inflation)^(-t)),
              socialsecurityincome=finances$socialsecurity * ((1 + parameters$inflation)^(-t)))
    numiter <- 2
    #finances$oldrate <- rep(1,T2)
    while(sum((finances$taxes$caprate - finances$capitalgainsrate)^2)>0){
        #print('function evals')
        #print(funevals)
        #print(finances$retirementIncome)
        #print(cbind(finances$taxes$rate,finances$capitalgainsrate))
        #finances$oldrate <- finances$capitalgainsrate
        #print(length(finances$returnHistory))
        #print(length(finances$capitalgainsrate))
        finances$capitalgainsrate <- finances$taxes$caprate
        X <- diag(T2) -
        rbind(rep(0,T2),cbind(diag(finances$returnHistory[2:T2-1] *
                                   (1-finances$capitalgainsrate[1:T2-1]/100)
                                   + 1),rep(0,T2-1)))
        #print(X)
        #print(finances$returnHistory[2:T2-1])
        #print(finances$capitalgainsrate[1:T2-1])
        #print(finances$returnHistory[2:T2-1] - finances$capitalgainsrate[1:T2-1])
        #print(dim(X))
        #print('made X')
        #rbind(rep(0,T2),cbind(diag(returnHistory[1:T2-1] * (1) + 1),rep(0,T2-1)))
        #Here I attempt to assume that all capital gains are realized as
        #accrued (which is totally weird since there's currently no
        #randomness in returns) but i could change this to be more
        #reasonable 

        q <- decisions$savingsRate*finances$laborincome - finances$retirementConsumptionPath * finances$retirementIncome
        q[1] <- q[1]+parameters$w0
        #head(X)
        #print(X)
        finances$savings <- solve(X) %*% q
        #print('solved!')
        #print(length(finances$savings))
        #print(length(decisions$retirementConsumptionPath))
        #print(pmax(finances$savings,0))
        finances$capitalgains <- finances$savings * finances$returnHistory 
        #print('im here')
        #* finances$capitalgainsrate / 100
        #print(cbind(finances$capitalgains,finances$savings))
        finances$socialsecurity <- calcSS(decisions,parameters,finances)
        #finances$taxes <- #Deflate income variables to current dollar values, then reinflate
            #taxes(income=finances$laborincome *
                  #((1+parameters$inflation)^(-t)),
                  #longtermcapitalgains=finances$capitalgains * ((1+parameters$inflation)^(-t)),
                  #socialsecurityincome=finances$socialsecurity * ((1 + parameters$inflation)^(-t)))
        #print(length(finances$socialsecurity))
        #print(length(finances$laborincome))
        #print(length(finances$capitalgains))
        #print(finances$socialsecurity)
        #print(finances$laborincome)
        #print(finances$capitalgains)
        finances$taxes <-
            taxes(income=finances$laborincome *
                  ((1+parameters$inflation)^(-t)),
                  longtermcapitalgains=finances$capitalgains * ((1+parameters$inflation)^(-t)),
                  socialsecurityincome=finances$socialsecurity * ((1 + parameters$inflation)^(-t)))
        finances$taxes$tax <- finances$taxes$tax * ((1+parameters$inflation)^(t))
        #finances$taxes <-
            #taxes(income=finances$laborincome,longtermcapitalgains=finances$capitalgains,socialsecurityincome=finances$ss)
        numiter <- numiter + 1
        funevals <- funevals + 1
        #print('made it here')
    }
    finances$netincome <- finances$laborincome - finances$taxes$tax + finances$capitalgains
    #Note: calcSS used to be called here and it worked
    finances$consumption <- (1-decisions$savingsRate) * finances$laborincome +
        finances$retirementConsumptionPath * decisions$retirementIncomeGoal -
        finances$taxes$tax + finances$socialsecurity
    
    return(finances)
}

calcSS <- function(decisions, parameters, finances){
    #This function calculates nominal social security payments given a lifetime
    #stream of earnings 
    type <- parameters$ssType
    t <- parameters$t
    T1 <- decisions$T1
    if (type == 'none') return(0)
    if (type == 'current'){
        ficamax <- 106800*(1+parameters$ssInflation)^(t-1)
        indexedIncome <-
            sapply(finances$laborincome,min,106800*(1+parameters$ssInflation)^(t-1))/(parameters$avgwage*(1+parameters$ssInflation)^(t-1))
        aime <- mean(sort(indexedIncome,decreasing=TRUE)[1:35])
        bp1 <- 180 /parameters$initwage
        bp2 <- 1085 /parameters$initwage
        piaFactor <- .9*min(aime,bp1) + .32*(min(aime,bp2)-bp1) + .15*min(aime-bp2,0)
        yearlyFactor <- 12 * piaFactor
        early <- earlyfactor(decisions,parameters)
        ss <- early * yearlyFactor * parameters$avgwage*(1+parameters$ssInflation)^(t-1) * (t >=T1)
        return(ss)
    }
    if (type == 'bowles-simpson'){
        #Bowles-Simpson is currently not implemented
        ficamax <- 106800*(1+parameters$ssInflation)^(t-1)
        indexedIncome <-
            sapply(finances$laborincome,min,106800*(1+parameters$ssInflation)^(t-1)) /(parameters$avgwage*(1+parameters$ssInflation)^(t-1))
        aime <- mean(sort(indexedIncome,decreasing=TRUE)[1:35])
        bp1 <- 180 /parameters$initwage
        bp2 <- 1085 /parameters$initwage
        piaFactor <- .9*min(aime,bp1) + .32*(min(aime,bp2)-bp1) + .15*min(aime-bp2,0)
        yearlyFactor <- 12 * piaFactor
        early <- earlyfactor(decisions,parameters)
        ss <- early * yearlyFactor * parameters$avgwage*(1+parameters$ssInflation)^(t-1) * (t >=T1)
        return(ss)
    }
    if (type == 'domenici-rivlin'){
        #Domenici-Rivlin is currently not implemented
        ficamax <- 106800*(1+parameters$ssInflation)^(t-1)
        indexedIncome <-
            sapply(finances$laborincome,min,106800*(1+parameters$ssInflation)^(t-1)) /(parameters$avgwage*(1+parameters$ssInflation)^(t-1))
        aime <- mean(sort(indexedIncome,decreasing=TRUE)[1:35])
        bp1 <- 180 /parameters$initwage
        bp2 <- 1085 /parameters$initwage
        piaFactor <- .9*min(aime,bp1) + .32*(min(aime,bp2)-bp1) + .15*min(aime-bp2,0)
        yearlyFactor <- 12 * piaFactor
        early <- earlyfactor(decisions,parameters)
        ss <- early * yearlyFactor * parameters$avgwage*(1+parameters$ssInflation)^(t-1) * (t >=T1)
        return(ss)
    }
}

laborincome <- function(initialIncome=50000,inflation = .02, T1= 40, t =
                        seq(1,70), type="Heckman", decisions,
                        parameters){

    if (type == "Heckman"){
        return((exp(initialIncome + .1301*t - .0023*t^2)*(1+inflation)^t) * (t < T1))
        #income comes from Heckman's 50 years of Mincer regressions:
        ##http://time.dufe.edu.cn/mingrendt/lochner030404.pdf, table 2 for white Men in 1990
    }
    else{
        me <- data.frame(race=factor(1,label=parameters$race),
                                    hispanic=factor(1,label=parameters$hispanic),
                                    educ=parameters$educ, a_age=parameters$myage+t-1)
        me$age2 <- me$a_age^2
        me$age3 <- me$a_age^3
        me$age4 <- me$a_age^4
        me$age5 <- me$a_age^5
        me$age6 <- me$a_age^6
        predictedlogincome <- predict(fullearnings,me)
        myresid <- log(initialIncome)-predictedlogincome[1]
        if (parameters$randomizeIncome == TRUE){
            y <- simulate.income(myresid,parameters)
            income <- exp(predictedlogincome + y)
        }
        else{
            income <- exp(myresid + predictedlogincome)
        }

        income[me$a_age > 85] <- income[85-parameters$myage]
        return((income*(1+inflation)^t))

    }
}

simulate.income <- function(y0,parameters){
    set.seed(parameters$seed)
    pi0 <- .0625
    pi1 <- .001985
    sig.w <- .00269
    sig.delta <- .0000383
    sig.mu0 <- .0901
    sig.mu.delta <- -.00019033
    rho <- .8468
    theta <- -.574
    a0 <- 20
    age <- parameters$myage
    T2 <- parameters$T2-1


    delta <- rnorm(1,mean=y0 * sig.mu.delta / sig.mu0,sd=sqrt(sig.delta - sig.mu.delta/sig.mu0))
    delta <- 0
    w0 <- y0 - delta
    b<-pi0+pi1*(seq(age,T2 + age -1)-a0)/10
    xi <- rnorm(T2,sd=sqrt(pi0+pi1*(seq(age,T2 + age -1)-a0)/10))
    w <- append(w0,rnorm(T2-1,sd=sqrt(sig.w)))
    L <- rbind(rep(0,T2),cbind(diag(T2-1),rep(0,T2-1)))
    #L <- cbind(rep(0,T2),rbind(diag(T2-1),rep(0,T2-1)))
    mu <- solve(diag(T2)-L) %*% (delta + w)
    nu <- solve(diag(T2) - rho* L) %*% (diag(T2) - theta * L) %*% xi
    y = append(y0,mu + nu)
    #plot(y,ylim=range(y,mu,nu),type="n")
    #lines(y,lty=1)
    #lines(mu,lty=2)
    #lines(nu,lty=3)
    ##points(xi,pch=1)
    ##points(w,pch=2)
    #legend(1,range(y,mu,nu)[2],c("y","mu","nu"),lty=1:3)
    return(y)

    #Note; it's a little ambiguous from their paper whether Gottschalk and
    #Moffit actually calibrate and report delta and w as age group changes or
    #age changes, so whether you get a new one when you go from your 30s to your
    #40s, or whether you get a new one every year.  Playing with the parameters,
    #if you go with the decade interpretation, so you would have to scale delta
    #and w down by .1, then you get really almost entirely transitory earnings
    #differences.
}

pension <- function(decisions, parameters){
    #This function calculates the final yearly permanent income, in real
    #terms, if a person saves at a given rate and gets ss under a given
    #rule, and retires at a certain time.  I will likely in the future make
    #this take income as an input too.

    #It returns a 'finances' object with the final yearly pension so that by
    #the end of life, money goes close to zero

    #Other things that we want to calculate:
    #401k
    #IRA
    #other savings
    #taxable capital gains
    #marginal tax rates
    #To do this, I think i want to make a single call to  taxsim and then
    #interpolate answers.  This isn't going to be quite the best
    #optimization, but should be alright mostly.  I need to vary the
    #following variables to determine taxes for a given individual under a
    #range of possible decisions:
        #income - from min to max
        #capital gains amounts - (here using just the avg return might be
                                 #weird)
        #Kids/marriage/other deducatinos
        # age
        #social security income
        #kid/dependents
        
    #T1 <- floor(as.double(parameters$retirementDate - parameters$today)/365.25) 
    T1 <- decisions$T1
    t <- parameters$t
   # calculate T1 based on retirement date
    parameters$potentialLaborIncome <- laborincome(initialIncome=parameters$initialIncome,
                                        inflation=parameters$inflation, T1=T1,t=t,
                                        parameters=parameters,decisions=decisions,
                                        type="Moffit-Gottschalk")
    #income <- parameters$potentialIncome
    #income[t>T1] <- 0

    #finances <- data.frame(t)
    #returnHistory <- rep(parameters$investmentReturn,parametersT2)
    #returnHistory[t>=T1] <- parameters$retirementInvestmentReturn
    #laborincome <- (exp(initialIncome + .1301*t - .0023*t^2)*(1+inflation)^t) * (t < T1)
    #print(parameters$initialIncome)
    #print(parameters$inflation)
    #print(finances$laborincome)
    #finances$retirementConsumptionPath <- ((1+inflation)^t) * (t >=T1)
    #print(finances$retirementConsumptionPath)
    #savingsRate <- sR


    optimal <- optim(par=50000,remaining, gr=NULL, decisions, parameters,
                     lower=10000, upper=1000000, method = "L-BFGS-B",
                     control=list(factr=1e4,maxit=10, trace=1))
    decisions$retirementIncomeGoal <- optimal$par
    finances <- calcFinance(decisions, parameters)
    finances$optimizationInfo <- optimal
    finances$decisions <- decisions
    finances$parameters <- parameters
    # Don't use these decisions and parameters: these are just for using
    # later
    return(finances)
}

