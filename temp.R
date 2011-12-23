func <- function(x){
    return(-x^3+10*x^2)
}
test <- function(x){
    a <- seq(1,30,by=3)
    b <- func(a)
    #c <- approx(a,b,xout=x)
    c <- spline(a,b,xout=x)
    return(c)
}
    a <- seq(1,30,by=3)
    b <- func(a)
    #c <- approx(a,b,xout=x)
d<-test(seq(1.5,40.5,by=1))
plot(a,b)
lines(d$x,d$y)
#New plan: make lists of each input (so incomes are every $1000 from 0 to 2
# million).  Then, use interp with a rounding type to find the nearest
# value in each dimension.  Then I can look up an exact value.  I think
# this woudl NOT be convex, but I would just hope that doesn't really
# matter.
d <- array(0,dim=c(length(a),length(b)))
vapply(X=c(6,1,12,-1),FUN=inv,FUN.VALUE=0,seq(0,10,by=2))

inv <- function(value,vec){
    #Right now I am trying to vectorize 'inv' so I can vectorize other parts
    #of the code, including indexvalue
    if (value > max(vec)){
        return(length(vec))
    }
    if (value <= min(vec)){
        return(0)
    }
    low <- sum(vec<value)
    high <- low+1
    lowv <- vec[low]
    highv <- vec[high]
    lowdiff <- abs(lowv-value)
    highdiff <- abs(highv-value)
    if (lowdiff < highdiff){
        return(low)
        #return(lowv)
        #return(list(key=low,value=lowv))
    }
    else{
        return(high)
        #return(highv)
        #return(list(key=high,value=highv))
    }
}
indexvalue <- function(aval,bval,dval){
    #this function takes 3 function values and returns the indexes that
    #would need to be used to look up the three dimensional function value.
    #So there's a function f(aval,bval,cval) that is represented by some
    #discreete points a1...an, b1...bn, and c1...cn, and we want to know
    #f(aval, bval, cval), but we really need to know the index ai, bi, ci,
    #which would best approximate f(aval, bval, cval).  
    # I would like to extend the function to take 3 equal length vectors
    # and one array representign f(a,b,c) and return a vector that is the
    # value of f for these vectors.
    print(length(e))
    print(e)
a<-seq(1000,10000,by=1000)
b<-seq(3,60,by=3)
d<-seq(12,120,by=12)
e <- expand.grid(a,b,d)
out<- e$Var1 * e$Var2 * e$Var3
    #apply(input,2,vapply,inv,FUN.VALUE=0,
    acall <- vapply(X=aval,FUN=inv,FUN.VALUE=0,a)
    bcall <- vapply(X=bval,FUN=inv,FUN.VALUE=0,b)
    dcall <- vapply(X=dval,FUN=inv,FUN.VALUE=0,d)
    print("made it to here!")
    print(c(acall,bcall,dcall))
    print(c(length(acall),length(bcall),length(dcall)))
    #acall <- inv(a,aval)
    #bcall <- inv(b,bval)
    #dcall <- inv(d,dval)
    print(c(length(a),length(b),length(d)))
    output <- array(out,dim=c(length(a),length(b),length(d)))
    print(c(a,b,d))
    #print(output)
    #The key insight here is expand.grid(a1,a2,a3) to
    #array(.,dim=c(a1,a2,a3)) is what orders things into a 3d array
    #return(list(output=output,val=output[acall$key,bcall$key,dcall$key]))
    #Used to have key and value returned from inv, and this worked
    return(list(output=output,val=output[cbind(acall,bcall,dcall)]))
}

N <- 30
v <- c(6500,31,55)
q <- t(matrix(v,dim=(N,length(v))))
mystuff<-indexvalue(array(seq(500,29*500+500,by=500)),array(rep(31,30)),array(rep(55,30)))
print(mystuff$val)
print(c(a$val,6500*31*55))
# Thoughts on what's going on: I ultimately have some different ranges of x
# values, and I will computer the tax rate for each of these x values.  One
# thing that's likely for me to do is to expand and contract the number of
# different x values (e.g. what if we were in Florida instead?).  At the
# beginning of running a particular version, I will make a single call of
# taxsim.  This is reasonable because while there is fairly high overhead
# for the call, the overhead isnt' absolutely so large that you wouldn't
# want to pay it once per run.  Therefore, given an individual's X's, we
# could determine initially what variables will be changing and their
# values.  Thus the way to start might be to take as given ranges of
# particular values (either going to the indexvalue function or not) and
# hard code these in.  On the other hand, if I did this, I would still
# probably want to expand or contract the NUMBER of varying assumptions, so
# it would be good for this to work on arbitrary numbers of columns.

#The 'out' variable here is already pre-determined from my external run for
#taxsim, as are the a, b, and c variables which went into the expand
#operation.