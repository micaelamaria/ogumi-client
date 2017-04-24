'use strict';

// return random color hex code
var getRandomColor = function() {
	var letters = '0123456789ABCDEF'.split('');
	var color = '#';
	for (var i = 0; i < 6; i++ ) {
		color += letters[Math.floor(Math.random() * 16)];
	}
	return color;
};

// create experimentChart and append to window
window.experimentChart = {

	container: "sessionChart",
	images: "",
	chart: null,
	showFuture: true,
	y0Min: null,
	y0Max: null,
	y1Min: null,
	y1Max: null,
	paged: null,
	stepsize: null,
	type: "linechart",
	player: null,
	colors: ['#007d00', '#ee7621', '#27408b', '#cd3278','#00868b','#7f7f7f', '#8b3a62','#000000', '#7d26cd', '#8b2500'],

	createCylindergaugeAxis: function(id, position, min, max) {
		var valueAxis = new AmCharts.ValueAxis();
		valueAxis.gridAlpha = 0;
		valueAxis.id = id;
		valueAxis.position = position;
		if(min !== null){
			valueAxis.minimum = min;
		}
		if(max !== null){
			valueAxis.maximum = max;
		}
		return valueAxis;
	},

	createLinegraphAxis: function(id, position, min, max) {
		var valueAxis = new AmCharts.ValueAxis();
		valueAxis.axisAlpha = 0.2;
		valueAxis.dashLength = 1;
		valueAxis.position = 'left';
		valueAxis.gridThickness = 2;
		valueAxis.gridAlpha = 0.25;
		valueAxis.minorGridAlpha = 0.15;
		valueAxis.minorGridEnabled = true;
		valueAxis.id = id;
		valueAxis.position = position;
		if(min !== null){
			valueAxis.minimum = min;
		}
		if(max !== null){
			valueAxis.maximum = max;
		}
		return valueAxis;
	},

	parseData: function(ret){
		var model = ret.model,
			chartData = model.data,
			graphs = [],
			i = 0,
			step = ret.step || 0,
			prop;
		// get data only for current step on cylinder gauge diagram
		if(experimentChart.type === "cylindergauge"){
			chartData = [chartData[ret.step]];
		} else {
			if(!experimentChart.showFuture){
				// show diagram with fixed axis length (paged)
				if(ret.step !== undefined) {
					if(ret.step <= experimentChart.paged){
						for(var i = -1; i >= ret.step-experimentChart.paged; i--){
							var firstObj = jQuery.extend(true, {}, model.data[0]);
							firstObj.time = i;
							chartData.unshift(firstObj);
						}
					}
				}
			}
		}
		// ignore graphs for other players if a player is set
		if(experimentChart.player != null){
			model.label = model.label.filter(function(elem){
				if(elem.indexOf('player[') >= 0){
					if(elem.indexOf('player['+experimentChart.player+']') >= 0){
						return true;
					}
					return false;
				}
				return true;
			});
		}
		if(AmCharts.isReady){
			if(experimentChart.chart === null || experimentChart.chart.graphs.length < model.label.length){
					experimentChart.chart = new AmCharts.AmSerialChart();
					experimentChart.chart.fontSize = 12;
					experimentChart.chart.theme = "none";
					experimentChart.chart.pathToImages = experimentChart.images;
					experimentChart.chart.legend = {
						"useGraphSettings": true,
						"fontSize": 14
					};
					var chartCursor = new AmCharts.ChartCursor();
					chartCursor.zoomable = false;
					experimentChart.chart.categoryField = 'time';
					//create cylinder gauge diagram
					if(experimentChart.type === "cylindergauge"){
						chartCursor.cursorAlpha = 0;
						chartCursor.categoryBalloonEnabled = false;
						var y0Axis = experimentChart.createCylindergaugeAxis('y0', 'left', experimentChart.y0Min, experimentChart.y0Max);
						experimentChart.chart.addValueAxis(y0Axis);
						var y1Axis = experimentChart.createCylindergaugeAxis('y1', 'left', experimentChart.y1Min, experimentChart.y1Max);
						y1Axis.offset = 50;
						experimentChart.chart.addValueAxis(y1Axis);
						var getBallonText = function (prop, graphDataItem, graph) {
							var value = graphDataItem.values.value;
							return '<b><span>'+Math.round(value * 100) /100+'</span></b>';
						};
						for(i = 0; i < model.label.length; i++){
							var prop = model.label[i];
							var graph = new AmCharts.AmGraph();
							graph.id = prop;
							graph.legendValueText = '[[description]]';
							var translatedProp = window.experimentTranslation(
								prop
									.replace('player['+experimentChart.player+'].', '')
									.replace('y1.', '')
							);
							graph.title = translatedProp;
							if(prop.indexOf('player['+experimentChart.player+']') >= 0){
								graph.title = window.experimentTranslation('your') + ' ' + graph.title;
							}
							if(prop.indexOf('y1.') >= 0){
								graph.valueAxis = 'y1';
								graph.title += ' ('+window.experimentTranslation('leftAxis')+')';
							} else {
								graph.valueAxis = 'y0';
								graph.title += ' ('+window.experimentTranslation('rightAxis')+')';
							}
							graph.valueField = prop;
							graph.type = 'column';
							graph.topRadius = 1;
							graph.columnWidth = 1;
							graph.showOnAxis = true;
							graph.lineThickness = 2;
							graph.lineAlpha = 0.5;
							graph.lineColor = '#FFFFFF';
							graph.fillColors = experimentChart.colors[i%experimentChart.colors.length];
							graph.fillAlphas = 0.8;
							graph.balloonFunction = getBallonText.bind(this, prop);
							experimentChart.chart.addGraph(graph);
						}
						var labelFun = function(valueText, serialDataItem, categoryAxis){
							return '⌚ '+valueText
						};
						experimentChart.chart.depth3D = 40;
						experimentChart.chart.angle = 30;
						experimentChart.chart.creditsPosition = 'top-right';
						categoryAxis = experimentChart.chart.categoryAxis;
						categoryAxis.axisAlpha = 0;
						categoryAxis.labelOffset = 40;
						categoryAxis.labelFunction = labelFun;
						categoryAxis.gridAlpha = 0;
				} else {
					//create linechart
					var getBallonText = function (prop, graphDataItem, graph) {
						var value = graphDataItem.values.value;
						var category = graphDataItem.category;
						return 'Step '+category+'<br/><b><span>'+graph.title+': '+Math.round(value * 100) /100+'</span></b>';
					};
					var y0Axis = experimentChart.createLinegraphAxis('y0', 'left', experimentChart.y0Min, experimentChart.y0Max);
					experimentChart.chart.addValueAxis(y0Axis);
					var y1Axis = experimentChart.createLinegraphAxis('y1', 'right', experimentChart.y1Min, experimentChart.y1Max);
					experimentChart.chart.addValueAxis(y1Axis);
					for(i = 0; i < model.label.length; i++){
						var prop = model.label[i];
						var graph = new AmCharts.AmGraph();
						graph.id = prop;
						graph.balloonFunction = getBallonText.bind(this, prop);
						graph.legendValueText = '[[description]]';
						graph.bullet = 'round';
						graph.bulletBorderAlpha = 1;
						graph.bulletColor = '#FFFFFF';
						graph.hideBulletsCount = 50;
						graph.lineThickness = 2;
						var translatedProp = window.experimentTranslation(
							prop
							.replace('player['+experimentChart.player+'].', '')
							.replace('y1.', '')
						);
						graph.title = translatedProp;
						if(prop.indexOf('player['+experimentChart.player+']') >= 0){
							graph.title = window.experimentTranslation('your') + ' ' + graph.title;
						}
						if(prop.indexOf('y1.') >= 0){
							graph.valueAxis = 'y1';
							graph.title += ' ('+window.experimentTranslation('rightAxis')+')';
						} else {
							graph.valueAxis = 'y0';
							graph.title += ' ('+window.experimentTranslation('leftAxis')+')';
						}
						graph.valueField = prop;
						graph.useLineColorForBulletBorder = true;
						experimentChart.chart.addGraph(graph);
					}
					var categoryAxis = experimentChart.chart.categoryAxis;
					categoryAxis.axisColor = "#DADADA";
					categoryAxis.dashLength = 1;
					categoryAxis.minorGridEnabled = true;
					categoryAxis.gridThickness = 2;
					categoryAxis.gridAlpha = 0.25;
					categoryAxis.minorGridAlpha = 0.15;
					experimentChart.chart.colors = experimentChart.colors;
				}
        experimentChart.chart.addChartCursor(chartCursor);
				experimentChart.chart.dataProvider = chartData;
				experimentChart.chart.write(experimentChart.container);
			}
			//replace old data
			experimentChart.chart.dataProvider = chartData;
			// add new guides, not on cylinder gauge diagram
			if(experimentChart.type !== "cylindergauge"){
				experimentChart.chart.categoryAxis.guides = [{
					category: ret.time,
					lineColor: "#CC0000",
					lineAlpha: 1,
					fillAlpha: 0.2,
					fillColor: "#CC0000",
					dashLength: 2,
					inside: true,
					labelRotation: 90,
					label: "current"
				}];
			}
			experimentChart.chart.validateData();
		}
	}
};
