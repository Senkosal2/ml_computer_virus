const prediction = document.getElementById('chart-prediction');
const analysis = document.getElementById('chart-analysis');
const malwareProbability = 0.82; // <--- Replace with your model prediction
const benignProbability = 1 - malwareProbability;
  new Chart(prediction, {
    type: 'bar',
    data: {
        labels: ['Malware', 'Benign'],
        datasets: [{
            label: 'Probability',
            data: [malwareProbability, benignProbability],
            backgroundColor: ['rgba(255, 99, 132, 0.6)', 'rgba(75, 192, 192, 0.6)'],
            borderWidth: 1
        }]
    },
    options: {
        indexAxis: 'y', // <--- Horizontal bar chart
        scales: {
            x: {
                beginAtZero: true,
                max: 1
            }
        }
    }
  });

const fpr = [0, 0.1, 0.2, 0.4, 1];  
const tpr = [0, 0.6, 0.8, 0.9, 1];

new Chart(analysis, {
    type: 'line',
    data: {
        labels: fpr,
        datasets: [{
            label: 'ROC Curve (AUC)',
            data: tpr,
            fill: true,
            backgroundColor: 'rgba(54, 162, 235, 0.2)',
            borderColor: 'rgba(54, 162, 235, 1)',
            borderWidth: 3,
            pointRadius: 5,
            pointBackgroundColor: 'rgba(54, 162, 235, 1)',
            tension: 0.3
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: { position: 'top' },
            tooltip: { mode: 'index', intersect: false }
        },
        scales: {
            x: {
                type: 'linear',
                min: 0,
                max: 1,
                title: { display: true, text: 'False Positive Rate', font: { size: 14 } }
            },
            y: {
                min: 0,
                max: 1,
                title: { display: true, text: 'True Positive Rate', font: { size: 14 } }
            }
        }
    }
});