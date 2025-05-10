library(reticulate)

# --- Python Setup ---
use_python("C:/Users/ASUS/AppData/Local/r-miniconda/python.exe", required = TRUE)
cv2 <- import("cv2")
np <- import("numpy", convert = FALSE)

# --- Load Images ---
img1 <- cv2$imread("000001.png", cv2$IMREAD_GRAYSCALE)
img2 <- cv2$imread("000002.png", cv2$IMREAD_GRAYSCALE)

img1 <- np$ascontiguousarray(img1, dtype = "uint8")
img2 <- np$ascontiguousarray(img2, dtype = "uint8")

# --- Detect GFTT Keypoints ---
gftt <- cv2$GFTTDetector_create(
  maxCorners = as.integer(1000),
  qualityLevel = 0.01,
  minDistance = as.integer(10),
  blockSize = as.integer(3),
  useHarrisDetector = FALSE,
  k = 0.04
)

kp1 <- gftt$detect(img1, NULL)
pt1 <- sapply(kp1, function(kp) c(kp$pt[[1]], kp$pt[[2]]))
pt1 <- t(pt1)  # shape (N, 2)

# --- Prepare for LK Optical Flow ---
pt1_np <- np$array(pt1, dtype = "float32")
pt1_py <- pt1_np$reshape(c(nrow(pt1), 1L, 2L))
flow <- cv2$calcOpticalFlowPyrLK(img1, img2, pt1_py, NULL)

# --- Extract results ---
pt2 <- flow[[1]]
status <- flow[[2]]
error <- flow[[3]]

pt2_r <- matrix(py_to_r(pt2), ncol = 2)
status_r <- as.integer(py_to_r(status))
error_r <- py_to_r(error)

# --- Compute Motion Magnitude ---
motion_vecs <- pt2_r - pt1
motion_mag <- sqrt(rowSums(motion_vecs^2))

# --- Summary ---
cat(sprintf("Tracked points: %d / %d\n", sum(status_r == 1), length(status_r)))
cat(sprintf("Motion: min = %.2f, max = %.2f, mean = %.2f px\n",
            min(motion_mag), max(motion_mag), mean(motion_mag)))

# --- Plot with arrows ---
img_matrix <- py_to_r(img1)
image(t(apply(img_matrix, 2, rev)), col = gray.colors(256), axes = FALSE,
      main = "Lucas-Kanade Optical Flow")

img_dims <- dim(img_matrix)
scale_x <- function(x) x / img_dims[2]
scale_y <- function(y) 1 - y / img_dims[1]

threshold <- 2.5
for (i in which(status_r == 1 & motion_mag > threshold)) {
  arrows(
    x0 = scale_x(pt1[i, 1]),
    y0 = scale_y(pt1[i, 2]),
    x1 = scale_x(pt2_r[i, 1]),
    y1 = scale_y(pt2_r[i, 2]),
    col = "red", length = 0.05, lwd = 1
  )
}

# Optional: export results
results <- data.frame(
  x1 = pt1[, 1], y1 = pt1[, 2],
  x2 = pt2_r[, 1], y2 = pt2_r[, 2],
  magnitude = motion_mag,
  status = status_r
)
write.csv(results, "flow_vectors.csv", row.names = FALSE)
