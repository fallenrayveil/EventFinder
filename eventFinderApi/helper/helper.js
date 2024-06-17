const multer = require('multer');
const fs = require('fs');
const path = require('path');
const axios = require('axios');

const extractCoordinatesFromUrl = (url) => {
    const regex = /@(-?\d+\.\d+),(-?\d+\.\d+)/;
    const matches = url.match(regex);
    if (matches) {
        return { lat: matches[1], lng: matches[2] };
    }
    return null;
};
  
  // Fungsi untuk mendapatkan URL redirect akhir dengan lebih baik meniru permintaan browser
const getRedirectUrl = async (url) => {
    try {
        const response = await axios.get(url, {
            maxRedirects: 5,
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
            }
        });
        console.log(response.request.res.responseUrl)
        return response.request.res.responseUrl;
    } catch (error) {
        console.error('Error fetching the redirect URL:', error);
        throw new Error('Invalid Google Maps URL');
    }
};

  // Helper function to delete image files
  const deleteImageFile = (filePath) => {
    fs.unlink(filePath, (err) => {
      if (err) {
        console.error(`Failed to delete file: ${filePath}`, err);
      } else {
        console.log(`Successfully deleted file: ${filePath}`);
      }
    });
  };

module.exports ={extractCoordinatesFromUrl,getRedirectUrl,deleteImageFile}