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
    ['$scope', 'Nutupane', '$location', '$http', '$compile',
    function($scope, Nutupane, $location, $http, $compile) {

        var columns = [{
            id: 'systemid',
            display: 'System ID',
            show: true
        },{
            id: 'status',
            display: 'Status',
            show: true
        },{
            id: 'hostname',
            display: 'Hostname',
            show: true
        },{
            id: 'splice_server',
            display: 'Satellite Server',
            show: true
        },{
            id: 'date',
            display: 'Checkin Time',
            show: true
        }];

        var transform = function(data){
            var rows = [];

            angular.forEach(data.systems,
                function(system){
                    var row = {
                        'row_id' : system._id["$oid"],
                        'show'  : true,
                        'cells': [{
                            //display: system.systemid,
                            display: $compile('<a ng-click="table.select_item(\'' + KT.routes.options.prefix + '/splice_reports/filters/' + Splice.filter_id + '/reports/record/?id=' + system._id["$oid"] + '\',\'' + system._id["$oid"] + '\')">' + system.systemid + '</a>')($scope),
                            column_id: 'systemid'
                        },{
                            display: system.status,
                            column_id: 'status'
                        },{
                            display: system.hostname,
                            column_id: 'hostname'
                        },{
                            display: system.splice_server,
                            column_id: 'splice_server'
                        },{
                            display: system.date,
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
            console.log(system)
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
                $scope.table.visible = false;

                // Only reset the active_item if an ID is provided
                if (id) {
                    // Remove all columns except name and replace them with the details pane
                    $scope.table.data.columns = nameColumn;
                    $scope.table.select_all(false);
                    $scope.table.active_item = system;
                    $scope.table.active_item.selected  = true;
                    $scope.rowSelect = false;
                }
                $scope.table.active_item.html = response.data;
            });
        };

        $scope.table.close_item = function () {
            $scope.table.visible = true;
            // Restore the former columns
            $scope.table.data.columns = allColumns;
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
