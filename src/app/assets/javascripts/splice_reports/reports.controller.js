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
            id: 'status',
            display: 'Status',
            show: true
        },{
            id: 'systemid',
            display: 'System ID',
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
                        'row_id' : system.status,
                        'show'  : true,
                        'cells': [{
                            //display: $compile('<a ng-click="select_item(\'' + system.uuid + '\')">' + system.name + '</a>')($scope),
                            display: system.status,
                            column_id: 'status'
                        },{
                            display: system.systemid,
                            column_id: 'systemid'
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
        $scope.table.url            = '/katello/splice_reports/reports/' + Splice.filter_id + '/items';
        $scope.table.transform      = transform;
        $scope.table.model          = 'Systems';
        $scope.table.data.columns   = columns;

        var allColumns = $scope.table.data.columns.slice(0);
        var nameColumn = $scope.table.data.columns.slice(0).splice(0, 1);


        $scope.select_item = function(id){
            $location.search('item', id);

            $http.get('/katello/api/splice_reports/reports/' + Splice.filter_id + 'items' + id, {
                params : {
                    expanded : true
                }
            })
            .then(function(response){
                $scope.table.visible = false;
                $scope.system = response.data;
                // Remove all columns except name and replace them with the details pane
                $scope.table.data.columns = nameColumn;
            });
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
