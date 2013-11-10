/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

/**
 * @ngdoc module
 * @name  Rollup
 *
 * @description
 *   Base module that defines the Katello reports engine's module
 *   namespace and includes any thirdparty modules used by the
 *   application.
 */

angular.module('Rollup', [
  // TODO: confirm whether or not other modules such as bastion
  // and alchemy need to be included here.
]);


/**
 * @ngdoc config
 * @name  Rollup.config
 *
 * @requires $httpProvider
 * @requires $urlRouterProvider
 *
 * @description
 *   Used for establishing application wide configuration such as adding the Rails CSRF token
 *   to every request.
 */
angular.module('Rollup').config(['$httpProvider', '$urlRouterProvider', function($httpProvider, $urlRouterProvider) {
    $httpProvider.defaults.headers.common['X-CSRF-TOKEN'] = $('meta[name=csrf-token]').attr('content');
    $httpProvider.defaults.headers.common['ACCEPT'] = 'application/json, text/plain, */*, version=2';
    $urlRouterProvider.otherwise("/");
}]);


/**
 * @ngdoc run
 * @name Rollup.run
 *
 * @requires $rootScope
 * @requires $state
 * @requires $stateParams
 * @requires gettextCatalog
 * @requires currentLocale
 *
 * @description
 *   Set up some common state related functionality and set the current language.
 */
angular.module('Rollup').run(['$rootScope', '$state', '$stateParams', 'gettextCatalog', 'currentLocale',
    function($rootScope, $state, $stateParams, gettextCatalog, currentLocale) {

        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;
        $rootScope.transitionTo = $state.transitionTo;

        $rootScope.isState = function (stateName) {
            return $state.is(stateName);
        };

        $rootScope.stateIncludes = $state.includes;

        // Set the current language
        gettextCatalog.currentLanguage = currentLocale;
    }
]);

