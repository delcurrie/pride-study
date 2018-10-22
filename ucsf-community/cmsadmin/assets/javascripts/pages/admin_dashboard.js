$(function() {

	var ctx_users = $('.users_graph')[0];
	var ctx_posts = $('.posts_graph')[0];
	var ctx_comments = $('.comments_graph')[0];
	var ctx_upvotes = $('.upvotes_graph')[0];
	var ctx_downvotes = $('.downvotes_graph')[0];

	Chart.defaults.global.legend.display = false;
	var data_users = {
	    labels: users_labels,
	    datasets: [
	        {
	            fill: false,
	            lineTension: 0.01,
	            backgroundColor: "rgba(75,192,192,0.4)",
	            borderColor: "rgba(0,0,0,1)",
	            borderWidth: 2,
	            borderCapStyle: 'round',
	            borderDash: [],
	            borderDashOffset: 0.0,
	            borderJoinStyle: 'miter',
	            pointBorderColor: "rgba(46,204,113,1)",
	            pointBorderWidth: 1,
	            pointHoverRadius: 0,
	            pointHoverBackgroundColor: "rgba(46,204,113,1)",
	            pointHoverBorderColor: "rgba(46,204,113,1)",
	            pointHoverBorderWidth: 0,
	            pointRadius: 1,
	            pointHitRadius: 10,
	            data: users_data,
	            spanGaps: false,
	        }
	    ]
	};

	var data_posts = {
	    labels: posts_labels,
	    datasets: [
	        {
	            fill: false,
	            lineTension: 0.01,
	            backgroundColor: "rgba(75,192,192,0.4)",
	            borderColor: "rgba(0,0,0,1)",
	            borderWidth: 2,
	            borderCapStyle: 'round',
	            borderDash: [],
	            borderDashOffset: 0.0,
	            borderJoinStyle: 'miter',
	            pointBorderColor: "rgba(46,204,113,1)",
	            pointBorderWidth: 1,
	            pointHoverRadius: 0,
	            pointHoverBackgroundColor: "rgba(46,204,113,1)",
	            pointHoverBorderColor: "rgba(46,204,113,1)",
	            pointHoverBorderWidth: 0,
	            pointRadius: 1,
	            pointHitRadius: 10,
	            data: posts_data,
	            spanGaps: false,
	        }
	    ]
	};

	var data_comments = {
	    labels: comments_labels,
	    datasets: [
	        {
	            fill: false,
	            lineTension: 0.01,
	            backgroundColor: "rgba(75,192,192,0.4)",
	            borderColor: "rgba(0,0,0,1)",
	            borderWidth: 2,
	            borderCapStyle: 'round',
	            borderDash: [],
	            borderDashOffset: 0.0,
	            borderJoinStyle: 'miter',
	            pointBorderColor: "rgba(46,204,113,1)",
	            pointBorderWidth: 1,
	            pointHoverRadius: 0,
	            pointHoverBackgroundColor: "rgba(46,204,113,1)",
	            pointHoverBorderColor: "rgba(46,204,113,1)",
	            pointHoverBorderWidth: 0,
	            pointRadius: 1,
	            pointHitRadius: 10,
	            data: comments_data,
	            spanGaps: false,
	        }
	    ]
	};

	var data_upvotes = {
	    labels: comments_labels,
	    datasets: [
	        {
	            fill: false,
	            lineTension: 0.01,
	            backgroundColor: "rgba(75,192,192,0.4)",
	            borderColor: "rgba(0,0,0,1)",
	            borderWidth: 2,
	            borderCapStyle: 'round',
	            borderDash: [],
	            borderDashOffset: 0.0,
	            borderJoinStyle: 'miter',
	            pointBorderColor: "rgba(46,204,113,1)",
	            pointBorderWidth: 1,
	            pointHoverRadius: 0,
	            pointHoverBackgroundColor: "rgba(46,204,113,1)",
	            pointHoverBorderColor: "rgba(46,204,113,1)",
	            pointHoverBorderWidth: 0,
	            pointRadius: 1,
	            pointHitRadius: 10,
	            data: upvotes_data,
	            spanGaps: false,
	        }
	    ]
	};

	var data_downvotes = {
	    labels: comments_labels,
	    datasets: [
	        {
	            fill: false,
	            lineTension: 0.01,
	            backgroundColor: "rgba(75,192,192,0.4)",
	            borderColor: "rgba(0,0,0,1)",
	            borderWidth: 2,
	            borderCapStyle: 'round',
	            borderDash: [],
	            borderDashOffset: 0.0,
	            borderJoinStyle: 'miter',
	            pointBorderColor: "rgba(46,204,113,1)",
	            pointBorderWidth: 1,
	            pointHoverRadius: 0,
	            pointHoverBackgroundColor: "rgba(46,204,113,1)",
	            pointHoverBorderColor: "rgba(46,204,113,1)",
	            pointHoverBorderWidth: 0,
	            pointRadius: 1,
	            pointHitRadius: 1,
	            data: downvotes_data,
	            spanGaps: false
	        }
	    ]
	};
	/*
hoverRadius	Number	4	Default point radius when hovered
hoverBorderWidth	Number	1	Default stroke width when hovered
	 */
	var options = {
	        lineThickness: 15,
	    	showLines: true,
	    	spanGaps: true,
	    	tooltips: {
	    		enabled: false,
	    	},
	    	hoverRadius: 0,
	    	hoverBorderWidth: 0,
			width: 25,
	        scales: {
	            xAxes: [{
	                display: false
	            }],
	            yAxes: [{
	                display: false
	            }],
	        }
	    };

	var usersChart = new Chart(ctx_users, {
	    type: 'line',
	    data: data_users,
	    options: options
	});

	var postsChart = new Chart(ctx_posts, {
	    type: 'line',
	    data: data_posts,
	    options: options
	});

	var commentsChart = new Chart(ctx_comments, {
	    type: 'line',
	    data: data_comments,
	    options: options
	});

	var upvotesChart = new Chart(ctx_upvotes, {
	    type: 'line',
	    data: data_upvotes,
	    options: options
	});

	var downvotesChart = new Chart(ctx_downvotes, {
	    type: 'line',
	    data: data_downvotes,
	    options: options
	});

	/*
	$('.js-recent').on("click", function(e){
		e.preventDefault();
		var url = $(this).attr("href");
		$.get( url , function( data ) {
		  for (var i = data.length - 1; i >= 0; i--) {
		  	console.log(data[i]);
		  }
		});
	});
	*/
});

