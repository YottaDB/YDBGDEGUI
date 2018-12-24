<!--
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
#   This source code contains the intellectual property         #
#   of its copyright holder(s), and is made available           #
#   under a license.  If you do not know the terms of           #
#   the license, please stop and do not read further.           #
#                                                               #
#################################################################
-->
<template>
<footer class="home-page-footer">
  <div id="footer_top">
  <div class="brg_shape_1" id="footer-brg_shape" data-stellar-ratio="1.5"></div>
  <div class="container content-holder">
    <!-- Social Media -->
    <socialMedia></socialMedia>
      <!-- Copyright -->
      <div class="row" id="footer-copyright">
        <div class="col-sm-16 col-sm-offset-4">
          © 2018 YottaDB, LLC. All Rights Reserved.
          <ul id="menu-footer-menu" class="menu">
            <li id="" class="menu-item">
              <a href="https://yottadb.com/about-us/privacy-policy/">Privacy</a>
            </li>
            <li id="" class="menu-item">
              <a href="https://yottadb.com/about-us/terms-of-use/">Terms</a>
            </li>
            <li id="" class="menu-item">
              <a href="https://yottadb.com/about-us/copyright-statement/">Copyright</a>
            </li>
            <li id="" class="menu-item">
              <a href="https://yottadb.com/product/license/">License</a>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
  <!-- Site Map -->
  <siteMap></siteMap>
</footer>
</template>

<script>
import socialMedia from '@/components/footer/socialMedia';
import siteMap from '@/components/footer/siteMap';

export default {
  name: 'mainFooter',
  components: { socialMedia, siteMap },
};
</script>

<style scoped>

</style>
