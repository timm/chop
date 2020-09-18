BEGIN {DOT="."; DASH="_"}
function transpile(s,  a) {
  if (s ~ /^@include/) 
    print s
  else {
    if (s ~ /^function[ \t]+[A-Z][^\(]*\(/) {
      split(s,a,/[ \t\(]/)
      Prefix = a[2] 
    }
    gsub(/_/,Prefix "_",s)
    print gensub( /\.([^0-9\\*\\$\\+])([a-zA-Z0-9_]*)/,
                  "[\"\\1\\2\"]","g",s)   }
}
function oo(a,prefix,    indent,   i,txt) {
  txt = indent ? indent : (prefix "." )
  if (!isarray(a)) {print(a); return a}
  ooSortOrder(a)
  for(i in a)  {
    if (isarray(a[i]))   {
      print(txt i"" )
      oo(a[i],"","|  " indent)
    } else
      print(txt i (a[i]==""?"": ": " a[i])) }
}
function ooSortOrder(a, i) {
  for (i in a)
   return PROCINFO["sorted_in"] =\
     typeof(i+1)=="number" ? "@ind_num_asc" : "@ind_str_asc"
}
function csv(a,file,     b4, status,line) {
  file   = file ? file : "-"           # [1]
  status = getline < file
  if (status<0) {
    print "#E> Missing file ["file"]"  # [2]
    exit 1
  }
  if (status==0) {
    close(file)
    return 0
  }                                    # [3]
  line = b4 $0                         # [4]
  gsub(/([ \t]*|#.*$)/, "", line)      # [5]
  if (!line)
    return csv(a,file, line)           # [6]
  if (line ~ /,$/)
    return csv(a,file, line)           # [4]
  split(line, a, ",")                  # [7]
  return 1
}

#### Conventions
### Objects
## - Objects are called `i` (and not `self`)

### Notataion
## - :str is a string
## - :num is a integer or float
## - :int is a number
## - :pos is a positive number
## - :atom is  a string or a number 
## - :list isa  list
## - :list0 is  a list or uninitialized 

### push(x:atom, a:list) :atom 
## Adds `x` to the end of `a`.
## Returns `x`.
function push(x,a)    { a[length(a)+1] =x; return x}

### isa(i:list0, thing:fun) :posint
## Ensures `i` is a `thing`.
## Resets `i` to the empty list, 
## then adds `i.isa=y` and `i.id=n` where `n` is a unique number.
## Returns  the newly created `i.id`.
function isa(i,y)     { List(i);i["id"] = ++Id; i["isa"]=y; return Id}

### List(i:list0) :nil
## Resets `i` to the empty list 
function List(i)      { split("",i,"") }

### has(i:list
function has(i,k,f)   { f=f?f:"List";zap(i,k); @f(i[k]) }
function hasmore(i,f) { has(i,length(i)+1, f); return length(i) } 

function zap(i,k)     { i[k][0]; List(i[k]) } 

function max(x,y) { return x>y ? x : y }
function min(x,y) { return x<y ? x : y }

function rogues(    s) {
  for(s in SYMTAB) 
    if (s ~ /^[A-Z][a-z]/) print "#W> Global " s>"/dev/stderr"
  for(s in SYMTAB) 
    if (s ~ /^[_a-z]/) print "#W> Rogue: " s>"/dev/stderr"
}
