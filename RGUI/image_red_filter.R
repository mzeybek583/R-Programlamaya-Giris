args <- commandArgs(trailingOnly = TRUE)
input_path <- args[1]
output_path <- args[2]

library(imager)

# G??rseli oku
img <- load.image(input_path)

# Boyutlar?? al
w <- dim(img)[1]
h <- dim(img)[2]

# K??rm??z?? kanal: oldu??u gibi
r <- R(img)

# Ye??il ve mavi kanallar?? s??f??rla
g <- as.cimg(rep(0, w * h), x = w, y = h)
b <- as.cimg(rep(0, w * h), x = w, y = h)

# 3 kanal olarak birle??tir
red_img <- imappend(list(r, g, b), "c")

# Kaydet
save.image(red_img, output_path)
