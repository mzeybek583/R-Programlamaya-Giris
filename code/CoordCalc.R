# ============================================================
# Total Station (gon) -> hedef nokta koordinat + kot hesaplama
# + 2 grafik:
#   (1) Plan gorunumu: durulan nokta (A), bakilan nokta (P), Hz aci yayiyla gosterim
#   (2) Dusey profil:
#       - A zemin -> alet merkezi: kesikli dikey
#       - alet merkezi -> prizma merkezi: duz cizgi (gorusu dogrusu)
#       - prizma merkezi -> P zemin: kesikli dikey
# Turkce karakter YOK, ama Turkce yazi var.
# Birimler:
#   - Aci: gon (grad)
#   - Mesafe: metre
# Varsayim:
#   - Hz, backsight 0 yapildiktan sonra kuzey referansli azimut gibi kullanilir
#   - Y: northing, X: easting
# ============================================================

gon_to_rad <- function(gon) gon * pi / 200
rad_to_gon <- function(rad) rad * 200 / pi

# ------------------------------------------------------------
# Hesap fonksiyonu
# ------------------------------------------------------------
compute_target_point <- function(YA, XA, HA, Hz_gon, Z_gon, S_m, i_m, h_m) {
  Az_rad <- gon_to_rad(Hz_gon)
  Z_rad  <- gon_to_rad(Z_gon)
  
  # Zenit acisi Z ile
  HD <- S_m * sin(Z_rad)  # yatay mesafe
  VD <- S_m * cos(Z_rad)  # dusey bilesen (asagi negatif olabilir)
  
  # Koordinat farklari
  dX <- HD * sin(Az_rad)
  dY <- HD * cos(Az_rad)
  
  # Hedef nokta
  XP <- XA + dX
  YP <- YA + dY
  HP <- HA + i_m + VD - h_m
  
  list(
    angles_rad = list(Az_rad = Az_rad, Z_rad = Z_rad),
    intermediate = list(HD = HD, VD = VD, dX = dX, dY = dY),
    result = list(XP = XP, YP = YP, HP = HP)
  )
}

# ------------------------------------------------------------
# Grafik 1: Plan gorunumu + Hz acisi (kuzeye gore)
# ------------------------------------------------------------
plot_plan_hz <- function(XA, YA, XP, YP, Hz_gon, arc_radius = NULL) {
  dist_ap <- sqrt((XP - XA)^2 + (YP - YA)^2)
  if (dist_ap == 0) stop("A ve P ayni noktada olamaz.")
  if (is.null(arc_radius)) arc_radius <- 0.30 * dist_ap
  
  Az_rad <- gon_to_rad(Hz_gon)
  
  # Referans: kuzey (+Y) dogrultusu
  ref_len <- 0.60 * dist_ap
  x_ref <- XA
  y_ref <- YA + ref_len
  
  # Hz dogrultusu (A->P yonu ile uyumlu gosterim)
  x_tar <- XA + (XP - XA) / dist_ap * ref_len
  y_tar <- YA + (YP - YA) / dist_ap * ref_len
  
  # Aci yayi: 0 -> Az
  t <- seq(0, Az_rad, length.out = 160)
  arc_x <- XA + arc_radius * sin(t)
  arc_y <- YA + arc_radius * cos(t)
  
  pad <- 0.20 * dist_ap
  xlim <- range(c(XA, XP, x_ref, x_tar, arc_x)) + c(-pad, pad)
  ylim <- range(c(YA, YP, y_ref, y_tar, arc_y)) + c(-pad, pad)
  
  plot(NA, NA, xlim = xlim, ylim = ylim, asp = 1,
       xlab = "X (Saga Deger)", ylab = "Y (Yukari Deger)",
       main = "Plan gorunumu: A -> P ve Azimut acisi")
  
  # A->P dogrusu
  segments(XA, YA, XP, YP, lwd = 2)
  
  # Kuzey referansi (kesikli)
  segments(XA, YA, x_ref, y_ref, lty = 2, lwd = 1.5)
  
  # Hz dogrultusu (noktalı)
  segments(XA, YA, x_tar, y_tar, lty = 3, lwd = 1.5)
  
  # Hz aci yayi
  lines(arc_x, arc_y, lwd = 2)
  
  # Noktalar
  points(XA, YA, pch = 19)
  points(XP, YP, pch = 19)
  
  text(XA, YA, labels = "A", pos = 2)
  text(XP, YP, labels = "P", pos = 4)
  
  mid_t <- Az_rad / 2
  tx <- XA + (arc_radius * 1.12) * sin(mid_t)
  ty <- YA + (arc_radius * 1.12) * cos(mid_t)
  text(tx, ty, labels = sprintf("Hz = %.4f grad", Hz_gon))
  
  mtext("Kesikli: kuzey referansi. Noktali: Az dogrultusu.", side = 3, line = 0.2, cex = 0.85)
}

# ------------------------------------------------------------
# Grafik 2: Dusey profil (istenen cizim duzeni)
# - A zemin -> alet merkezi: kesikli dikey
# - alet merkezi -> prizma merkezi: duz cizgi
# - prizma merkezi -> P zemin: kesikli dikey
# ------------------------------------------------------------
plot_vertical_profile <- function(HA, i_m, h_m, HD, VD, HP) {
  H_inst <- HA + i_m
  H_prism_center <- HA + i_m + VD
  H_target_ground <- HP
  
  ymin <- min(HA, H_target_ground, H_inst, H_prism_center) - 1
  ymax <- max(HA, H_target_ground, H_inst, H_prism_center) + 1
  
  plot(NA, NA,
       xlim = c(-0.05 * HD, 1.05 * HD),
       ylim = c(ymin, ymax),
       xlab = "Yatay mesafe HD (m)",
       ylab = "Yukseklik H (m)",
       main = "Dusey profil: A dan P ye")
  
  # Istersen zemin hattini goster (A zemin -> P zemin)
  lines(c(0, HD), c(HA, H_target_ground), lwd = 2)
  
  # 1) A zemin -> alet merkezi (kesikli)
  segments(0, HA, 0, H_inst, lwd = 2, lty = 2)
  
  # 2) alet merkezi -> prizma merkezi (duz)
  segments(0, H_inst, HD, H_prism_center, lwd = 2, lty = 1)
  
  # 3) prizma merkezi -> P zemin (kesikli)
  segments(HD, H_prism_center, HD, H_target_ground, lwd = 2, lty = 2)
  
  # Noktalar ve etiketler
  points(0, HA, pch = 19); text(0, HA, "A noktasi", pos = 4)
  points(0, H_inst, pch = 19); text(0, H_inst, sprintf("Alet merkezi (HA+i)=%.3f", H_inst), pos = 4)
  points(HD, H_prism_center, pch = 19); text(HD, H_prism_center, sprintf("Prizma merkezi=%.3f", H_prism_center), pos = 2)
  points(HD, H_target_ground, pch = 19); text(HD, H_target_ground, sprintf("P noktasi (HP)=%.3f", HP), pos = 4)
  
  # Bilgi yazilari
  text(HD/2, (HA + H_target_ground)/2, labels = sprintf("HD = %.3f m", HD), pos = 3)
  text(HD/2, (H_inst + H_prism_center)/2, labels = sprintf("VD = %.3f m", VD), pos = 1)
  
  mtext(sprintf("i = %.2f m, h = %.2f m", i_m, h_m), side = 3, line = 0.2, cex = 0.85)
}

# ------------------------------------------------------------
# ORNEK: Senin sayilarinla calistir
# ------------------------------------------------------------
YA <- 5000.000
XA <- 3000.000
HA <- 102.350

i_m <- 1.60
h_m <- 1.80

S_m    <- 45.230
Z_gon  <- 102.389
Hz_gon <- 39.111

out <- compute_target_point(
  YA = YA, XA = XA, HA = HA,
  Hz_gon = Hz_gon, Z_gon = Z_gon,
  S_m = S_m, i_m = i_m, h_m = h_m
)

HD <- out$intermediate$HD
VD <- out$intermediate$VD
XP <- out$result$XP
YP <- out$result$YP
HP <- out$result$HP

cat("----- Ara hesaplar -----\n")
cat(sprintf("HD (m) = %.3f\n", HD))
cat(sprintf("VD (m) = %.3f\n", VD))
cat(sprintf("dX (m) = %.3f\n", out$intermediate$dX))
cat(sprintf("dY (m) = %.3f\n", out$intermediate$dY))

cat("\n----- Sonuc (P noktasi) -----\n")
cat(sprintf("XP = %.3f\n", XP))
cat(sprintf("YP = %.3f\n", YP))
cat(sprintf("HP = %.3f\n", HP))

# Grafikler
par(mfrow = c(1, 2))
plot_plan_hz(XA = XA, YA = YA, XP = XP, YP = YP, Hz_gon = Hz_gon)
plot_vertical_profile(HA = HA, i_m = i_m, h_m = h_m, HD = HD, VD = VD, HP = HP)
par(mfrow = c(1, 1))
