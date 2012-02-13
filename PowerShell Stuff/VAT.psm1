function forvat 
{
  $stuff = $args #apparently args gets wiped out going through the pipeline
  "BA,BR,GA,GE,GR,HD,HO,IL,KA,KL,LU,MA,MI,PU,RA,SF,SN,SP,ST,WI,DEV".split(",") | foreach-object {
    write-host -nonewline "executing $_... "
    invoke-expression "$stuff" 
  }
}

# e.g.: forvatsql -Q `"print `''$_'`'`"
function forvatsql
{
  forvat "sqlcmd -S mwr-tro-`$_\mssql2008 -d iTRAAC $args"
}
