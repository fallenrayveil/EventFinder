// middleware/errorHandler.js
const errorHandler = (err, req, res, next) => {
    console.error(err.stack);
  
    if (res.headersSent) {
      return next(err);
    }
  
    const status = err.status || 500;
    const response = {
      error: {
        message: err.message,
        status,
      },
    };
  
    if (err.errors) {
      response.error.details = err.errors;
    }
  
    res.status(status).json(response);
  };
  
  module.exports = errorHandler;
  