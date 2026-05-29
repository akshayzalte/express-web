# Cloud Dental Express GitHub Pages Deployment Script
Write-Host "Deploying Flutter Web to GitHub Pages..." -ForegroundColor Cyan

if (-Not (Test-Path "build/web")) {
    Write-Host "Error: build/web folder not found. Build the project first." -ForegroundColor Red
    Exit
}

# Go into the build/web directory
Push-Location "build/web"

# Initialize Git in the build directory if not already initialized
if (-Not (Test-Path ".git")) {
    git init
    git checkout -b gh-pages
}

# Configure local git user if not globally set
git config user.email "express@dental.com"
git config user.name "Cloud Dental Developer"

# Add and commit the compiled web files
git add .
git commit -m "Deploy web build to GitHub Pages"

# Ensure remote origin is set
git remote remove origin 2>$null
git remote add origin https://github.com/akshayzalte/express-web.git

# Force push to the gh-pages branch
Write-Host "Pushing files to GitHub gh-pages branch..." -ForegroundColor Yellow
git push -f origin gh-pages

# Return to root directory
Pop-Location

Write-Host "Successfully completed! Your app will be live shortly on GitHub Pages." -ForegroundColor Green
