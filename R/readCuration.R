
ST = readLines("../data/subtypes_curation.txt", n=51)

dflist <- list()
for (i in seq(from=1, to=51, by=3)){
  print(i)
  df = as.data.frame(strsplit(ST[c(i, i+1)], "\t"))
  colnames(df) = t(df[1, ])
  df = df[-1, ]
  df = df[!df[, 1] %in% "", ]
  dflist[[colnames(df)[2]]] = df
}


