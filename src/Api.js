import axios from 'axios'

// note that environment variables that should be available in the browser
// need to start with VITE_* 
var backend = import.meta.env.VITE_BACKEND_HOST || 'localhost'
var port = import.meta.env.VITE_BACKEND_PORT || '5045'
var protocol = import.meta.env.VITE_BACKEND_PROTOCOL || 'http'

// format: http://localhost:5000/api
var backendApiEndpoint = protocol + '://' + backend + ':' + port + '/api'
console.log('Using backend endpoint: ' + backendApiEndpoint)

export const Api = axios.create({
  baseURL: backendApiEndpoint
})
