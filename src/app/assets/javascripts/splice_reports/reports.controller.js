/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/


//= require "alchemy/jquery/plugins/ui.spinner"
//= require "alchemy/jquery/plugins/jquery.sortElements"
//= require "alchemy/jquery/plugins/jquery.multiselect"
//= require "alchemy/jquery/plugins/jquery.multiselect.filter"
//= require "alchemy/jquery/plugins/chosen.jquery"
//= require "alchemy/jquery/plugins/jquery.treeTable"
//= require "widgets/auto_complete"


angular.module('Katello').controller('ReportsController',
    ['$scope', 'Nutupane', '$location', '$filter', '$http', '$compile',
    function($scope, Nutupane, $location, $filter, $http, $compile) {

        var columns = [{
            id: 'hostname',
            display: 'Hostname',
            show: true 
        },{
            id: 'systemid',
            display: 'System ID',
            show: true
        },{
            id: 'status',
            display: 'Status',
            show: true
        },{
            id: 'splice_server',
            display: 'Satellite Server',
            show: true
        },{
            id: 'organization_name',
            display: 'Organization',
            show: true
        },{
            id: 'date',
            display: 'Check-In Time',
            show: true
        }];

        var transform = function(data){
            var rows = [];

            angular.forEach(data.systems,
                function(system){
                    var date = new Date(system.checkin_date)
                    var row = {
                        'row_id' : system.record["$oid"],
                        'show'  : true,
                        'cells': [{
                            //display: system.systemid,
                            display: $compile('<a ng-click="table.select_item(\'' + KT.routes.options.prefix + '/splice_reports/filters/' + Splice.filter_id + '/reports/record/?id=' + system.record["$oid"] + '\',\'' + system.record["$oid"] + '\')">' + system.hostname +  '</a>')($scope),
                            column_id: 'hostname'
                        },{
                            display: system.systemid,
                            column_id: 'systemid'
                        },{
                            display: system.status,
                            column_id: 'status'
                        },{
                            display: system.splice_server,
                            column_id: 'splice_server'
                        },{
                            display: system.organization_name,
                            column_id: 'organization_name'
                        },{
                            //display: $filter('date')(system.date, 'medium'),
                            display: date.toUTCString().replace("GMT", "+0000"),
                            column_id: 'date'
                        }]
                    };
                    rows.push(row);
                });

            return {
                rows    : rows,
                total   : data.total,
                subtotal: data.subtotal
            };
        };

        $scope.table                = Nutupane.table;
        $scope.table.url            = KT.routes.options.prefix + '/splice_reports/filters/' + Splice.filter_id + '/reports/items';
        $scope.table.transform      = transform;
        $scope.table.model          = 'Systems';
        $scope.table.data.columns   = columns;

        var allColumns = $scope.table.data.columns.slice(0);
        var nameColumn = $scope.table.data.columns.slice(0).splice(0, 1);


        $scope.table.select_item = function(url, id){
            var system;
            console.log(url)
            if (id) {
                angular.forEach($scope.table.data.rows, function(row) {
                    if (row.row_id.toString() === id.toString()) {
                        system = row;
                    }
                });
            }
            url = url ? url : KT.routes.edit_system_path(id);

            $http.get(url, {
                params : {
                    expanded : true
                }
            })
            .then(function(response){
                $("#nutupane-details").show(); 
                $scope.table.visible = false;

                // Only reset the active_item if an ID is provided
                if (id) {
                    // Remove all columns except name and replace them with the details pane
                    $scope.table.data.columns = nameColumn;
                    $scope.table.select_all(false);
                    $scope.table.active_item = system;
                    $scope.table.active_item.selected  = false;
                    $scope.rowSelect = true;
                }
                $scope.table.active_item.html = response.data;
            });
        };

        $scope.table.close_item = function () {
            $scope.table.visible = true;
            // Restore the former columns
            $scope.table.data.columns = allColumns;
            $("#nutupane-details").hide(); 
        };
        $scope.close_item = function () {
            $location.search("");
            $scope.table.visible = true;
            // Restore the former columns
            $scope.table.data.columns = allColumns;
        };

        if( $location.search().item ){
            $scope.select_item($location.search().item);
        }

        Nutupane.get();
    }]
);
