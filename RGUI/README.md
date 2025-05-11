# 🔴 R Image Red Filter GUI

This is a simple R-based graphical tool that lets you select an image and convert it into a red-tone image using `imager` and `tcltk`. The GUI runs without opening RStudio and is launched via `.bat` or `.exe`.

---

## 📦 Features

- Select an input image (PNG, JPG)
- Save output image with red channel only
- GUI created using `tcltk` (no external frameworks)
- Portable `.bat` launcher

---

## 🧰 Requirements

- R (tested with R 4.4.3)
- R packages:
  - `imager`
  - `tcltk` (comes built-in with R)

---

## 📁 File Locations

All application files are located in this folder:

R-Programlamaya-Giris/RGUI/
├── gui_tcltk.R # Main GUI file
├── image_red_filter.R # Image processing script
├── run_gui.bat # Windows batch launcher

---

## 🚀 How to Run

### 1. Install Required Packages

In R:

```r
install.packages("imager")


2. Run the GUI
Option 1: Double-click the .bat file:

bash
R-Programlamaya-Giris/RGUI/run_gui.bat

Option 2: Run manually via terminal:

bash
"C:\Program Files\R\R-4.4.3\bin\x64\Rscript.exe" R-Programlamaya-Giris/RGUI/gui_tcltk.R
