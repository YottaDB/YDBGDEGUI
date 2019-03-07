/*
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#   This source code contains the intellectual property         #
#   of its copyright holder(s), and is made available           #
#   under a license.  If you do not know the terms of           #
#   the license, please stop and do not read further.           #
#                                                               #
#################################################################
*/

import Vue from 'vue';
import Router from 'vue-router';
import gde from '@/components/systemAdministration/gde';

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: '/',
      name: 'gde',
      component: gde,
    },
  ],
});
