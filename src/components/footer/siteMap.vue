<!--
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
-->
<template>
  <div id="footer_sitemap">
    <div
      id="footer_toggle_one"
      class="ydb_circle ydb_sitemap_toggle toggle"
      data-toggle="#ydb_sitemap_holder"
      data-linked="#footer_toggle_two"/>
    <div
      id="sitemap-desc"
      class="text-center">Sitemap</div>
    <div id="ydb_sitemap_holder">
      <div
        id="footer_toggle_two"
        class="ydb_circle ydb_sitemap_toggle toggle"
        data-toggle="#ydb_sitemap_holder"
        data-linked="#footer_toggle_one"/>
      <div class="container">
        <div class="row content-holder">
          <div
            id="footer-nav"
            class="col-sm-24 nav">
            <ul
              id="menu-main-menu-2"
              class="menu">
              <li class="menu-item menu-item-has-children">
                <a href="https://yottadb.com/product/">Product</a>
                <ul class="sub-menu">
                  <li class="menu-item">
                    <a href="https://yottadb.com/product/features/">Features</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/product/how-it-works/">How It Works</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/product/core-technology/">Core Technology</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/product/services/">Services</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/whats-new/">What&#8217;s New</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/product/get-started/">Get Started</a>
                  </li>
                </ul>
              </li>
              <li class="menu-item menu-item-has-children">
                <a href="https://yottadb.com/use-cases/">Use Cases</a>
                <ul class="sub-menu">
                  <li class="menu-item">
                    <a href="https://yottadb.com/use-cases/transactional-systems/">Transactional Systems</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/use-cases/health-records/">Health Records</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/use-cases/internet-of-things/">Internet of Things</a>
                  </li>
                  <li class="menu-item menu-item-75">
                    <a href="https://yottadb.com/use-cases/gt-m-compatibility/">GT.M Compatibility</a>
                  </li>
                </ul>
              </li>
              <li class="menu-item menu-item-has-children">
                <a href="https://yottadb.com/resources/">Resources</a>
                <ul class="sub-menu">
                  <li class="menu-item">
                    <a href="https://yottadb.com/resources/documentation/">Documentation</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/resources/presentations/">Presentations</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/resources/communities/">Communities</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/resources/success-stories/">Success Stories</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/resources/faq/">FAQ</a>
                  </li>
                </ul>
              </li>
              <li class="menu-item menu-item-has-children">
                <a href="https://yottadb.com/about-us/">About Us</a>
                <ul class="sub-menu">
                  <li class="menu-item">
                    <a href="https://yottadb.com/about-us/team/">Team</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/about-us/ecosystem/">Ecosystem</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/about-us/careers/">Careers</a>
                  </li>
                  <li class="menu-item">
                    <a href="https://yottadb.com/about-us/contact/">Contact Us</a>
                  </li>
                </ul>
              </li>
              <li class="menu-item">
                <a href="https://yottadb.com/blog/">Blog</a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SiteMap',
  data() {
    return {
      menus: {
        main: [
          {
            name: 'System Administraton',
            url: '#',
            submenus: [
              {
                name: 'Global Directory Editor (GDE)',
                url: 'gde',
              },
              {
                name: 'Data Structure Editor (DSE)',
                url: '#',
              },
              {
                name: 'SQL Management',
                url: '#',
              },
              {
                name: 'Web Server',
                url: '#',
              },
              {
                name: 'Call-In Management',
                url: '#',
              },
              {
                name: 'Call-Out Management',
                url: '#',
              },
            ],
          },
          {
            name: 'Monitoring',
            url: '#',
            submenus: [
              {
                name: 'InfoHub',
                url: '#',
              },
              {
                name: 'gvstat',
                url: '#',
              },
              {
                name: 'Database Performance',
                url: '#',
              },
              {
                name: 'SQL Cached Queries',
                url: '#',
              },
              {
                name: 'Web Server',
                url: '#',
              },
            ],
          },
          {
            name: 'Resources',
            url: '#',
            submenus: [
              {
                name: 'Documentation',
                url: 'https://yottadb.com/resources/documentation/',
              },
            ],
          },
        ],
      },
    };
  },
};
</script>

<style scoped>

</style>
