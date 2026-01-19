
const functionApi = 'https://resume-api-tlcyotqq.azurewebsites.net/api/GetResumeCounter'; 

/**
 * Retrieves or generates a unique visitor ID stored in localStorage.
 */
const getVisitorId = () => {
    let vid = localStorage.getItem('visitor_id');
    
    if (!vid) {
        // Generates a RFC4122 version 4 compliant UUID
        vid = crypto.randomUUID(); 
        localStorage.setItem('visitor_id', vid);
    }
    return vid;
};

/**
 * Calls the Azure Function to record the visit and update the UI.
 */
const getVisitCount = () => {
    const vid = getVisitorId();
    
    // Append the visitorId to the API call as a query parameter
    fetch(`${functionApi}?visitorId=${vid}`)
        .then(response => {
            if (!response.ok) throw new Error('Network response was not ok');
            return response.json();
        })
        .then(data => {
            const counterElement = document.getElementById('counter');
            if (counterElement) {
                counterElement.innerText = data.count;
            }
        })
        .catch(error => {
            console.error("Error fetching counter:", error);
        });
};

// Initialize the counter once the DOM is ready
window.addEventListener('DOMContentLoaded', getVisitCount);