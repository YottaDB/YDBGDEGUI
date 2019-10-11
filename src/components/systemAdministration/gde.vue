<!--
#################################################################
#                                                               #
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries. #
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
  <b-container fluid>
    <b-alert
      :show="!saved"
      fade
      variant="danger"
      class="fixed-top">Not Saved!
    </b-alert>
    <b-row class="fixed-header">
      <b-col cols="3">
        <b-form-input
          v-model="filter"
          placeholder="Type to Search" />
      </b-col>
      <b-col>
        <b-btn
          :disabled="!filter"
          @click="filter = ''">Clear</b-btn>
      </b-col>
      <b-col offset="4">
        <b-btn
          :pressed.sync="advancedToggle"
          @click="advanced = !advanced">Advanced</b-btn>
        <b-btn
          :pressed.sync="savedToggle"
          @click="savedata">Save</b-btn>
        <b-btn v-b-modal.modalAdd>Add</b-btn>
      </b-col>
    </b-row>

    <!-- Names -->
    <b-row>
      <b-col>
        <h4>Names</h4>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        <b-table
          :striped="striped"
          :hover="hover"
          :items="items"
          :fields="fields"
          :filter="filter"
          :sort-by.sync="sortBy"
          :sort-desc.sync="sortDesc"
          :sort-direction="sortDirection"
          show-empty>
          <template
            slot="actions"
            slot-scope="row">
            <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
            <b-btn
              v-b-modal.modalEditName
              @click="info(row.item)">Edit</b-btn>
            <b-btn
              v-if="show(row.item)"
              variant="danger"
              @click="remove(row.item,'name')">Delete</b-btn>
            <!-- we use @click.stop here to prevent emitting of a 'row-clicked' event -->
            <b-button
              class="mr-2"
              @click.stop="row.toggleDetails">{{ row.detailsShowing ? 'Hide' : 'Show' }} Details
            </b-button>
          </template>
          <template
            slot="row-details"
            slot-scope="row">
            <b-card>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Segment:</b>
                </b-col>
                <b-col>{{ row.item.segment }}</b-col>
              </b-row>
              <b-button @click="row.toggleDetails">Hide Details</b-button>
            </b-card>
          </template>
        </b-table>
      </b-col>
    </b-row>

    <!-- Regions -->
    <b-row>
      <b-col>
        <h4>Regions</h4>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        <b-table
          :striped="striped"
          :hover="hover"
          :items="regionItems"
          :fields="regionFields"
          :filter="filter"
          :sort-by.sync="sortBy"
          :sort-desc.sync="sortDesc"
          :sort-direction="sortDirection"
          show-empty>
          <template
            slot="actions"
            slot-scope="row">
            <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
            <b-btn
              v-b-modal.modalEditRegion
              @click="info(row.item)">Edit</b-btn>
            <b-btn
              variant="danger"
              @click="remove(row.item,'region')">Delete</b-btn>
            <!-- we use @click.stop here to prevent emitting of a 'row-clicked' event  -->
            <b-button
              class="mr-2"
              @click.stop="row.toggleDetails">
              {{ row.detailsShowing ? 'Hide' : 'Show' }} Details
            </b-button>
          </template>
          <template
            slot="row-details"
            slot-scope="row">
            <b-card>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Journal Extension Count:</b></b-col>
                <b-col>{{ row.item.extensionCount }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Journal Auto Switch Limit:</b></b-col>
                <b-col>{{ row.item.autoSwitchLimit }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Default Collation:</b></b-col>
                <b-col>{{ row.item.defaultCollation }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Stats:</b></b-col>
                <b-col>{{ row.item.stats }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>AutoDB:</b></b-col>
                <b-col>{{ row.item.autodb }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Lock Crit:</b></b-col>
                <b-col>{{ row.item.lockCrit }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Null Subscripts:</b></b-col>
                <b-col>{{ row.item.nullSubscripts }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Standard Null Collation:</b></b-col>
                <b-col>{{ row.item.standardNullCollation }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Instance Freeze On Error:</b></b-col>
                <b-col>{{ row.item.instFreezeOnError }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Qdb Rundown:</b></b-col>
                <b-col>{{ row.item.qDbRundown }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Epoch Taper:</b></b-col>
                <b-col>{{ row.item.epochTaper }}</b-col>
              </b-row>
              <b-button @click="row.toggleDetails">Hide Details</b-button>
            </b-card>
          </template>
        </b-table>
      </b-col>
    </b-row>

    <!-- Segments -->
    <b-row>
      <b-col>
        <h4>Segments</h4>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        <b-table
          :striped="striped"
          :hover="hover"
          :items="segmentItems"
          :fields="segmentFields"
          :filter="filter"
          :sort-by.sync="sortBy"
          :sort-desc.sync="sortDesc"
          :sort-direction="sortDirection"
          show-empty>
          <template
            slot="actions"
            slot-scope="row">
            <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
            <b-btn
              v-b-modal.modalEditSegment
              @click="info(row.item)">Edit</b-btn>
            <b-btn
              variant="danger"
              @click="remove(row.item,'segment')">Delete</b-btn>
            <!-- we use @click.stop here to prevent emitting of a 'row-clicked' event  -->
            <b-button
              class="mr-2"
              @click.stop="row.toggleDetails">{{ row.detailsShowing ? 'Hide' : 'Show' }} Details
            </b-button>
          </template>
          <template
            slot="row-details"
            slot-scope="row">
            <b-card>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Reserved Bytes:</b></b-col>
                <b-col>{{ row.item.reservedBytes }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Encryption:</b></b-col>
                <b-col>{{ row.item.encryption }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Mutex Slots:</b></b-col>
                <b-col>{{ row.item.mutexSlots }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Defer Allocation:</b></b-col>
                <b-col>{{ row.item.deferAllocate }}</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col
                  sm="3"
                  class="text-sm-right"><b>Async IO:</b></b-col>
                <b-col>{{ row.item.asyncIO }}</b-col>
              </b-row>
              <b-button @click="row.toggleDetails">Hide Details</b-button>
            </b-card>
          </template>
        </b-table>
      </b-col>
    </b-row>

    <!-- Map -->
    <b-row v-if="advanced">
      <b-col>
        <h4>Global Mapping</h4>
      </b-col>
    </b-row>
    <b-row v-if="advanced">
      <b-col>
        <b-table
          :striped="striped"
          :hover="hover"
          :items="map"
          :fields="mapFields"
          :filter="filter"
          :sort-by.sync="sortBy"
          :sort-desc.sync="sortDesc"
          :sort-direction="sortDirection"
          responsive="false"
          show-empty/>
      </b-col>
    </b-row>

    <!-- Add modal -->
    <b-modal
      id="modalAdd"
      ref="modalAdd"
      size="lg"
      title="Add to Global Directory"
      @hide="resetModal"
      @ok="ok(addType)"
    >
      <b-row>
        <b-col>
          <b-form-group
            horizontal
            label="Type:">
            <b-form-radio-group
              id="addType"
              v-model="addType"
              :options="addOptions"
              name="addType"
              inline
            />
          </b-form-group>
        </b-col>
      </b-row>
      <b-form>
        <b-form-group>

          <!-- Add name -->
          <b-input-group v-if="addType==='name'">
            <b-row>
              <b-col>
                <label for="name">Name:</label>
              </b-col>
              <b-col>
                <b-input
                  id="name"
                  v-model="selectedItem.name.NAME"
                  :value="selectedItem.name.NAME"
                  :state="!$v.selectedItem.name.NAME.$invalid"
                  aria-describedby="nameLiveFeedback"/>
                <b-form-invalid-feedback id="nameLiveFeedback">
                  This is a required field
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="region">Region:</label>
              </b-col>
              <b-col>
                <b-select
                  id="region"
                  :options="regions"
                  v-model="selectedItem.name.REGION"
                  :value="selectedItem.name.REGION"
                  :state="!$v.selectedItem.name.REGION.$invalid"
                  aria-describedby="regionLiveFeedback"/>
                <b-form-invalid-feedback id="regionLiveFeedback">
                  This is a required field
                </b-form-invalid-feedback>
              </b-col>
            </b-row>
          </b-input-group>

          <!-- Add Segment -->
          <b-input-group v-if="addType==='segment'">
            <b-row>
              <b-col>
                <label for="segment">Segment:</label>
              </b-col>
              <b-col>
                <b-input
                  id="segment"
                  v-model="selectedItem.segment.NAME"
                  :value="selectedItem.segment.NAME"
                  :state="!$v.selectedItem.segment.NAME.$invalid"
                  style="text-transform: uppercase;"
                  aria-describedby="nameLiveFeedback"
                  @input="forceUpper($event, selectedItem.segment, 'NAME')"/>
                <b-form-invalid-feedback id="nameLiveFeedback">
                  This is a required field
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="file">File:</label>
              </b-col>
              <b-col>
                <b-input
                  id="file"
                  v-model="selectedItem.segment.FILE_NAME"
                  :value="selectedItem.segment.FILE_NAME"
                  :state="!$v.selectedItem.segment.FILE_NAME.$invalid"
                  aria-describedby="fileNameLiveFeedback"/>
                <b-form-invalid-feedback id="fileNameLiveFeedback">
                  This is a required field
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="accessMethod">Access Method:</label>
              </b-col>
              <b-col>
                <b-select
                  id="accessMethod"
                  :options="accessMethods"
                  v-model="selectedItem.segment.ACCESS_METHOD"
                  :value="selectedItem.segment.ACCESS_METHOD"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="allocation">Allocation (blocks):</label>
              </b-col>
              <b-col>
                <b-input
                  id="allocation"
                  v-model="selectedItem.segment.ALLOCATION"
                  :state="!$v.selectedItem.segment.ALLOCATION.$invalid"
                  aria-describedby="allocationLiveFeedback"/>
                <b-form-invalid-feedback id="allocationLiveFeedback">
                  This must be numeric
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="asyncio">Async IO:</label>
              </b-col>
              <b-col>
                <b-check
                  id="asyncio"
                  v-model="selectedItem.segment.ASYNCIO"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="blockSize">
                  Block Size (bytes & multiple of 512):
                </label>
              </b-col>
              <b-col>
                <b-input
                  id="blockSize"
                  v-model="selectedItem.segment.BLOCK_SIZE"
                  :state="!$v.selectedItem.segment.BLOCK_SIZE.$invalid"
                  aria-describedby="blockSizeLiveFeedback"/>
                <b-form-invalid-feedback id="blockSizeLiveFeedback">
                  This must be numeric
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="deferAllocate">Defer Allocate:</label>
              </b-col>
              <b-col>
                <b-check
                  id="deferAllocate"
                  v-model="selectedItem.segment.DEFER_ALLOCATE"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="encryption">Encryption:</label>
              </b-col>
              <b-col>
                <b-check
                  id="encryption"
                  v-model="selectedItem.segment.ENCRYPTION_FLAG"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="extensionCount">Extension Count:</label>
              </b-col>
              <b-col>
                <b-input
                  id="extensionCount"
                  v-model="selectedItem.segment.EXTENSION_COUNT"
                  :state="!$v.selectedItem.segment.EXTENSION_COUNT.$invalid"
                  aria-describedby="extensionCountLiveFeedback"/>
                <b-form-invalid-feedback id="extensionCountLiveFeedback">
                  This must be numeric
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="globalBufferCount">
                  Global Buffer Count (blocks):
                </label>
              </b-col>
              <b-col>
                <b-input
                  id="globalBufferCount"
                  v-model="selectedItem.segment.GLOBAL_BUFFER_COUNT"
                  :state="!$v.selectedItem.segment.GLOBAL_BUFFER_COUNT.$invalid"
                  aria-describedby="GlobalBufferCountLiveFeedback"/>
                <b-form-invalid-feedback id="GlobalBufferCountLiveFeedback">
                  This must be numeric
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="lockSpace">Lock Space (pages):</label>
              </b-col>
              <b-col>
                <b-input
                  id="lockSpace"
                  v-model="selectedItem.segment.LOCK_SPACE"
                  :state="!$v.selectedItem.segment.LOCK_SPACE.$invalid"
                  aria-describedby="lockSpaceLiveFeedback"/>
                <b-form-invalid-feedback id="lockSpaceLiveFeedback">
                  This must be numeric
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="mutexSlots">Mutex Slots:</label>
              </b-col>
              <b-col>
                <b-input
                  id="mutexSlots"
                  v-model="selectedItem.segment.MUTEX_SLOTS"
                  :state="!$v.selectedItem.segment.MUTEX_SLOTS.$invalid"
                  aria-describedby="mutexSlotsLiveFeedback"/>
                <b-form-invalid-feedback id="mutexSlotsLiveFeedback">
                  This must be numeric
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="reservedBytes">Reserved Bytes:</label>
              </b-col>
              <b-col>
                <b-input
                  id="reservedBytes"
                  v-model="selectedItem.segment.RESERVED_BYTES"
                  :state="!$v.selectedItem.segment.RESERVED_BYTES.$invalid"
                  aria-describedby="reservedBytesLiveFeedback"/>
                <b-form-invalid-feedback id="reservedBytesLiveFeedback">
                  This must be numeric
                </b-form-invalid-feedback>
              </b-col>
            </b-row>
          </b-input-group>

          <!-- Add Region -->
          <b-input-group v-if="addType==='region'">
            <b-row>
              <b-col>
                <label for="region">Region:</label>
              </b-col>
              <b-col>
                <b-input
                  id="region"
                  v-model="selectedItem.region.NAME"
                  :value="selectedItem.region.NAME"
                  :state="!$v.selectedItem.region.NAME.$invalid"
                  style="text-transform: uppercase;"
                  aria-describedby="nameLiveFeedback"
                  @input="forceUpper($event, selectedItem.region, 'NAME')"/>
                <b-form-invalid-feedback id="nameLiveFeedback">
                  This is a required field
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="segment">Segment:</label>
              </b-col>
              <b-col>
                <b-select
                  id="segment"
                  :options="segments"
                  v-model="selectedItem.region.DYNAMIC_SEGMENT"
                  :value="selectedItem.region.DYNAMIC_SEGMENT"
                  :state="!$v.selectedItem.region.DYNAMIC_SEGMENT.$invalid"
                  aria-describedby="dynamicSegmentLiveFeedback"/>
                <b-form-invalid-feedback id="dynamicSegmentLiveFeedback">
                  This is a required field
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="autodb">AutoDB:</label>
              </b-col>
              <b-col>
                <b-check
                  id="autodb"
                  v-model="selectedItem.region.AUTODB"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="collationDefault">
                  Collation Default:
                </label>
              </b-col>
              <b-col>
                <b-input
                  id="collationDefault"
                  v-model="selectedItem.region.COLLATION_DEFAULT"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="epochTaper">Epoch Taper:</label>
              </b-col>
              <b-col>
                <b-check
                  id="epochTaper"
                  v-model="selectedItem.region.EPOCHTAPER"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="instFreezeOnError">
                  Instance Freeze on Error:
                </label>
              </b-col>
              <b-col>
                <b-check
                  id="instFreezeOnError"
                  v-model="selectedItem.region.INST_FREEZE_ON_ERROR"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="journal">
                  Enable Journal:
                </label>
              </b-col>
              <b-col>
                <b-check
                  id="journal"
                  v-model="selectedItem.region.JOURNAL"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="autoSwitchLimit">
                  Auto Switch Limit:
                </label>
              </b-col>
              <b-col>
                <b-input
                  id="autoSwitchLimit"
                  v-model="selectedItem.region.AUTOSWITCHLIMIT"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="beforeImage">Before Image:</label>
              </b-col>
              <b-col>
                <b-check v-model="selectedItem.region.BEFORE_IMAGE"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="journalFileName">
                  Journal File Name:
                </label>
              </b-col>
              <b-col>
                <b-input
                  id="journalFileName"
                  v-model="selectedItem.region.FILE_NAME"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="keySize">Key Size (bytes):</label>
              </b-col>
              <b-col>
                <b-input
                  id="keySize"
                  v-model="selectedItem.region.KEY_SIZE"
                  :state="!$v.selectedItem.region.KEY_SIZE.$invalid"
                  aria-describedby="keySizeLiveFeedback"/>
                <b-form-invalid-feedback id="keySizeLiveFeedback">
                  This must be numeric
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="lockCrit">Lock Crit Separate:</label>
              </b-col>
              <b-col>
                <b-check
                  id="lockCrit"
                  v-model="selectedItem.region.LOCK_CRIT_SEPARATE"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="nullSubscripts">Null Subscripts:</label>
              </b-col>
              <b-col>
                <b-select
                  id="nullSubscripts"
                  v-model="selectedItem.region.NULL_SUBSCRIPTS"
                  :options="regionNullSubscriptsOptions"
                  :value="selectedItem.region.NULL_SUBSCRIPTS"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="qDbRundown">
                  Quick Database Rundown:
                </label>
              </b-col>
              <b-col>
                <b-check
                  id="qDbRundown"
                  v-model="selectedItem.region.QDBRUNDOWN"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="recordSize">Record Size (bytes):</label>
              </b-col>
              <b-col>
                <b-input
                  id="recordSize"
                  v-model="selectedItem.region.RECORD_SIZE"
                  :state="!$v.selectedItem.region.RECORD_SIZE.$invalid"
                  aria-describedby="recordSizeLiveFeedback"/>
                <b-form-invalid-feedback id="recordSizeLiveFeedback">
                  This must be numeric
                </b-form-invalid-feedback>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="stats">Stats:</label>
              </b-col>
              <b-col>
                <b-check
                  id="stats"
                  v-model="selectedItem.region.STATS"/>
              </b-col>
              <!-- Row Break -->
              <div class="w-100"/>
              <b-col>
                <label for="standardNullCollation">
                  Standard Null Collation:
                </label>
              </b-col>
              <b-col>
                <b-check
                  id="standardNullCollation"
                  v-model="selectedItem.region.STDNULLCOLL"/>
              </b-col>
            </b-row>
          </b-input-group>
        </b-form-group>
      </b-form>
      <div slot="modal-footer" >
        <b-btn
          :disabled="$v.selectedItem.$invalid"
          size="sm"
          variant="primary"
          @click="ok(addType)">OK</b-btn>
        <b-btn
          size="sm"
          variant="warning"
          @click="cancel()">Cancel</b-btn>
      </div>
    </b-modal>

    <!-- Edit Name Modal -->
    <b-modal
      id="modalEditName"
      ref="modalEditName"
      size="lg"
      title="Edit Name"
      @hide="resetModal"
      @shown="focusElement">
      <b-form-group horizontal>
        <b-input-group>
          <b-row>
            <b-col>
              <label for="name">Name:</label>
            </b-col>
            <b-col>
              <b-input
                id="name"
                ref="infoName"
                v-model="selectedItem.name.NAME"
                :value="selectedItem.name.NAME"
                disabled/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="region">Region:</label>
            </b-col>
            <b-col>
              <b-select
                id="region"
                :options="regions"
                v-model="selectedItem.name.REGION"
                :value="selectedItem.name.REGION"/>
            </b-col>
          </b-row>
        </b-input-group>
      </b-form-group>
      <div slot="modal-footer" >
        <b-btn
          size="sm"
          variant="primary"
          @click="ok('name')">OK</b-btn>
        <b-btn
          size="sm"
          variant="warning"
          @click="cancel()">Cancel</b-btn>
      </div>
    </b-modal>

    <!-- Edit Segment Modal -->
    <b-modal
      id="modalEditSegment"
      ref="modalEditSegment"
      size="lg"
      title="Edit Segment"
      @hide="resetModal">
      <b-form-group>
        <b-input-group>
          <b-row>
            <b-col>
              <label for="segment">Segment:</label>
            </b-col>
            <b-col>
              <b-input
                id="segment"
                v-model="selectedItem.segment.NAME"
                :value="selectedItem.segment.NAME"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="file">File:</label>
            </b-col>
            <b-col>
              <b-input
                id="file"
                v-model="selectedItem.segment.FILE_NAME"
                :value="selectedItem.segment.FILE_NAME"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="accessMethod">Access Method:</label>
            </b-col>
            <b-col>
              <b-select
                id="accessMethod"
                :options="accessMethods"
                v-model="selectedItem.segment.ACCESS_METHOD"
                :value="selectedItem.segment.ACCESS_METHOD"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="allocation">Allocation (blocks):</label>
            </b-col>
            <b-col>
              <b-input
                id="allocation"
                v-model="selectedItem.segment.ALLOCATION"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="asyncio">Async IO:</label>
            </b-col>
            <b-col>
              <b-check
                id="asyncio"
                v-model="selectedItem.segment.ASYNCIO"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="blockSize">
                Block Size (bytes & multiple of 512):
              </label>
            </b-col>
            <b-col>
              <b-input
                id="blockSize"
                v-model="selectedItem.segment.BLOCK_SIZE"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="deferAllocate">Defer Allocate:</label>
            </b-col>
            <b-col>
              <b-check
                id="deferAllocate"
                v-model="selectedItem.segment.DEFER_ALLOCATE"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="encryption">Encryption:</label>
            </b-col>
            <b-col>
              <b-check
                id="encryption"
                v-model="selectedItem.segment.ENCRYPTION_FLAG"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="extensionCount">Extension Count:</label>
            </b-col>
            <b-col>
              <b-input
                id="extensionCount"
                v-model="selectedItem.segment.EXTENSION_COUNT"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="globalBufferCount">
                Global Buffer Count (blocks):
              </label>
            </b-col>
            <b-col>
              <b-input
                id="globalBufferCount"
                v-model="selectedItem.segment.GLOBAL_BUFFER_COUNT"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="lockSpace">Lock Space (pages):</label>
            </b-col>
            <b-col>
              <b-input
                id="lockSpace"
                v-model="selectedItem.segment.LOCK_SPACE"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="mutexSlots">Mutex Slots:</label>
            </b-col>
            <b-col>
              <b-input
                id="mutexSlots"
                v-model="selectedItem.segment.MUTEX_SLOTS"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="reservedBytes">Reserved Bytes:</label>
            </b-col>
            <b-col>
              <b-input
                id="reservedBytes"
                v-model="selectedItem.segment.RESERVED_BYTES"/>
            </b-col>
          </b-row>
        </b-input-group>
      </b-form-group>
      <div slot="modal-footer" >
        <b-btn
          size="sm"
          variant="primary"
          @click="ok('segment')">OK</b-btn>
        <b-btn
          size="sm"
          variant="warning"
          @click="cancel()">Cancel</b-btn>
      </div>
    </b-modal>

    <!-- Edit Region Modal -->
    <b-modal
      id="modalEditRegion"
      ref="modalEditRegion"
      size="lg"
      title="Edit Region"
      @hide="resetModal">
      <b-form-group>
        <b-input-group>
          <b-row>
            <b-col>
              <label for="region">Region:</label>
            </b-col>
            <b-col>
              <b-input
                id="region"
                v-model="selectedItem.region.NAME"
                :value="selectedItem.region.NAME"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="segment">Segment:</label>
            </b-col>
            <b-col>
              <b-select
                id="segment"
                :options="segments"
                v-model="selectedItem.region.DYNAMIC_SEGMENT"
                :value="selectedItem.region.DYNAMIC_SEGMENT"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="autodb">AutoDB:</label>
            </b-col>
            <b-col>
              <b-check
                id="autodb"
                v-model="selectedItem.region.AUTODB"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="collationDefault">
                Collation Default:
              </label>
            </b-col>
            <b-col>
              <b-input
                id="collationDefault"
                v-model="selectedItem.region.COLLATION_DEFAULT"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="epochTaper">Epoch Taper:</label>
            </b-col>
            <b-col>
              <b-check
                id="epochTaper"
                v-model="selectedItem.region.EPOCHTAPER"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="instFreezeOnError">
                Instance Freeze on Error:
              </label>
            </b-col>
            <b-col>
              <b-check
                id="instFreezeOnError"
                v-model="selectedItem.region.INST_FREEZE_ON_ERROR"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="journal">
                Enable Journal:
              </label>
            </b-col>
            <b-col>
              <b-check
                id="journal"
                v-model="selectedItem.region.JOURNAL"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="autoSwitchLimit">
                Auto Switch Limit:
              </label>
            </b-col>
            <b-col>
              <b-input
                id="autoSwitchLimit"
                v-model="selectedItem.region.AUTOSWITCHLIMIT"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="beforeImage">Before Image:</label>
            </b-col>
            <b-col>
              <b-check
                v-model="selectedItem.region.BEFORE_IMAGE"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="journalFileName">
                Journal File Name:
              </label>
            </b-col>
            <b-col>
              <b-input
                id="journalFileName"
                v-model="selectedItem.region.FILE_NAME"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="keySize">Key Size (bytes):</label>
            </b-col>
            <b-col>
              <b-input
                id="keySize"
                v-model="selectedItem.region.KEY_SIZE"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="lockCrit">Lock Crit:</label>
            </b-col>
            <b-col>
              <b-check
                id="lockCrit"
                v-model="selectedItem.region.LOCK_CRIT_SEPARATE"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="nullSubscripts">Null Subscripts:</label>
            </b-col>
            <b-col>
              <b-select
                id="nullSubscripts"
                v-model="selectedItem.region.NULL_SUBSCRIPTS"
                :options="regionNullSubscriptsOptions"
                :value="selectedItem.region.NULL_SUBSCRIPTS"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="qDbRundown">
                Quick Database Rundown:
              </label>
            </b-col>
            <b-col>
              <b-check
                id="qDbRundown"
                v-model="selectedItem.region.QDBRUNDOWN"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="recordSize">Record Size (bytes):</label>
            </b-col>
            <b-col>
              <b-input
                id="recordSize"
                v-model="selectedItem.region.RECORD_SIZE"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="stats">Record Size (bytes):</label>
            </b-col>
            <b-col>
              <b-check
                id="stats"
                v-model="selectedItem.region.STATS"/>
            </b-col>
            <!-- Row Break -->
            <div class="w-100"/>
            <b-col>
              <label for="standardNullCollation">
                Standard Null Collation:
              </label>
            </b-col>
            <b-col>
              <b-check
                id="standardNullCollation"
                v-model="selectedItem.region.STDNULLCOLL"/>
            </b-col>
          </b-row>
        </b-input-group>
      </b-form-group>
      <div slot="modal-footer" >
        <b-btn
          size="sm"
          variant="primary"
          @click="ok('region')">OK</b-btn>
        <b-btn
          size="sm"
          variant="warning"
          @click="cancel()">Cancel</b-btn>
      </div>
    </b-modal>

    <!-- Error modal -->
    <b-modal
      id="modalError"
      ref="modalError"
      size="lg"
      title="Errors"
      ok-only
      @hide="resetModal"
      @ok="okError">{{ errors }}
    </b-modal>
  </b-container>
</template>

<script>
import axios from 'axios';
import { validationMixin } from 'vuelidate';
import { required, numeric } from 'vuelidate/lib/validators';

const regions = [''];
const segments = [''];
const accessMethods = [''];

export default {
  name: 'Gde',
  mixins: [
    validationMixin,
  ],
  data() {
    return {
      version: [],
      fromSave: false,
      deletedItems: [],
      unsavedItems: {
        names: [],
        regions: [],
        segments: [],
      },
      saved: true,
      savedToggle: false,
      advanced: false,
      advancedToggle: false,
      items: [],
      regionItems: [],
      segmentItems: [],
      names: {},
      errors: '',
      addType: 'name',
      addOptions: [
        { text: 'Name', value: 'name' },
        { text: 'Segment', value: 'segment' },
        { text: 'Region', value: 'region' },
      ],
      regionNullSubscriptsOptions: [
        { text: 'Always', value: 'ALWAYS' },
        { text: 'Never', value: 'NEVER' },
        { text: 'Existing', value: 'EXISTING' },
      ],
      regions,
      segments,
      accessMethods,
      map: [],
      fields: [
        { key: 'displayName', label: 'Name', sortable: true, sortDirection: 'desc', class: 'fixed-width-font', thStyle: 'width: 15%' },
        { key: 'region', label: 'Region', sortable: true, thStyle: 'width: 15%' },
        { key: 'file', label: 'File', sortable: true, class: 'fixed-width-font', thStyle: 'width: 50%' },
        { key: 'actions', label: 'Actions', thStyle: 'width: 20%' },
      ],
      regionFields: [
        { key: 'name', label: 'Region', sortable: true, sortDirection: 'desc', class: 'fixed-width-font', thStyle: 'width: 5%' },
        { key: 'segment', label: 'Dynamic Segment', sortable: true, class: 'fixed-width-font', thStyle: 'width: 7%' },
        { key: 'keySize', label: 'Key Size', sortable: true, thStyle: 'width: 7%' },
        { key: 'recordSize', label: 'Record Size', sortable: true, thStyle: 'width: 7%' },
        { key: 'beforeImage', label: 'Before Image Journaling', sortable: true, thStyle: 'width: 7%' },
        { key: 'journal', label: 'Journaling Enabled', sortable: true, thStyle: 'width: 7%' },
        { key: 'journalFileName', label: 'Journal File Name', sortable: true, sortDirection: 'desc', class: 'fixed-width-font', thStyle: 'width: 26%' },
        { key: 'bufferSize', label: 'Journal Buffer Size', sortable: true, thStyle: 'width: 7%' },
        { key: 'allocation', label: 'Journal Allocation', sortable: true, thStyle: 'width: 7%' },
        { key: 'actions', label: 'Actions', thStyle: 'width: 20%' },
      ],
      segmentFields: [
        { key: 'name', label: 'Segment', sortable: true, sortDirection: 'desc', class: 'fixed-width-font', thStyle: 'width: 5%' },
        { key: 'fileName', label: 'File Name', sortable: true, class: 'fixed-width-font', thStyle: 'width: 26%' },
        { key: 'accessMethod', label: 'Access Method', sortable: true, thStyle: 'width: 7%' },
        { key: 'type', label: 'File Type', sortable: true, thStyle: 'width: 7%' },
        { key: 'blockSize', label: 'Block Size', sortable: true, thStyle: 'width: 7%' },
        { key: 'allocation', label: 'Database Allocation Count', sortable: true, thStyle: 'width: 7%' },
        { key: 'extensionCount', label: 'Database Extension Count', sortable: true, thStyle: 'width: 7%' },
        { key: 'globalBufferCount', label: 'Global Buffer Count', sortable: true, thStyle: 'width: 7%' },
        { key: 'lockSpace', label: 'Lock Space', sortable: true, thStyle: 'width: 7%' },
        { key: 'actions', label: 'Actions', thStyle: 'width: 20%' },
      ],
      mapFields: [
        { key: 'from', label: 'From', sortable: true, sortDirection: 'desc', class: 'fixed-width-font' },
        { key: 'to', label: 'Up to', sortable: true, class: 'fixed-width-font' },
        { key: 'region', label: 'Region', sortable: true, class: 'fixed-width-font' },
        { key: 'segment', label: 'Segment', sortable: true, class: 'fixed-width-font' },
        { key: 'file', label: 'File Name', sortable: true, class: 'fixed-width-font' },
      ],
      sortBy: 'name',
      sortDesc: false,
      sortDirection: 'asc',
      filter: null,
      striped: true,
      hover: true,
      fixed: true,
      selectedIndex: null,
      verified: false,
      modified: false,
      selectedItem: {
        name: {
          NAME: '',
          REGION: 'DEFAULT',
        },
        segment: {
          NAME: '',
          FILE_NAME: '',
          ACCESS_METHOD: 'BG',
          ALLOCATION: 100,
          ASYNCIO: false,
          BLOCK_SIZE: 1024,
          DEFER_ALLOCATE: true,
          ENCRYPTION_FLAG: false,
          EXTENSION_COUNT: 100,
          GLOBAL_BUFFER_COUNT: 1024,
          LOCK_SPACE: 40,
          MUTEX_SLOTS: 1024,
          RESERVED_BYTES: 0,
        },
        region: {
          NAME: '',
          DYNAMIC_SEGMENT: 'DEFAULT',
          AUTODB: false,
          COLLATION_DEFAULT: 0,
          EPOCHTAPER: true,
          INST_FREEZE_ON_ERROR: false,
          JOURNAL: false,
          AUTOSWITCHLIMIT: '',
          BEFORE_IMAGE: false,
          FILE_NAME: '',
          KEY_SIZE: 64,
          LOCK_CRIT_SEPARATE: true,
          NULL_SUBSCRIPTS: 'ALWAYS',
          QDBRUNDOWN: false,
          RECORD_SIZE: 256,
          STATS: true,
          STDNULLCOLL: true,
        },
      },
    };
  },
  computed: {
    sortOptions() {
      const self = this;

      // Create an options list from our fields
      return self.fields
        .filter(f => f.sortable)
        .map(f => ({ text: f.label, value: f.key }));
    },
  },
  mounted() {
    const self = this;
    self.getdata();
  },
  validations() {
    switch (this.addType) {
      case 'name':
        return {
          selectedItem: {
            name: {
              NAME: {
                required,
              },
              REGION: {
                required,
              },
            },
          },
        };
      case 'segment':
        return {
          selectedItem: {
            segment: {
              NAME: {
                required,
              },
              FILE_NAME: {
                required,
              },
              EXTENSION_COUNT: {
                numeric,
              },
              ALLOCATION: {
                numeric,
              },
              BLOCK_SIZE: {
                numeric,
              },
              GLOBAL_BUFFER_COUNT: {
                numeric,
              },
              LOCK_SPACE: {
                numeric,
              },
              MUTEX_SLOTS: {
                numeric,
              },
              RESERVED_BYTES: {
                numeric,
              },
            },
          },
        };
      case 'region':
        return {
          selectedItem: {
            region: {
              NAME: {
                required,
              },
              DYNAMIC_SEGMENT: {
                required,
              },
              KEY_SIZE: {
                numeric,
              },
              RECORD_SIZE: {
                numeric,
              },
            },
          },
        };
      default:
        break;
    }
    return {};
  },
  methods: {
    forceUpper(e, obj, prop) {
      this.$set(obj, prop, e.toUpperCase());
    },
    show(item) {
      switch (item.name) {
        case '*':
          return false;
        case '#': // Also known as Local Locks
          return false;
        default:
          return true;
      }
    },
    info(item) {
      const self = this;
      self.boundItem = item;

      // Make unbound clones of the item object
      self.cachedItem = Object.assign({}, item);
      self.selectedItem = {
        name: {
          NAME: item.name,
          REGION: item.region,
        },
        segment: {
          NAME: item.name,
          FILE_NAME: item.fileName,
          ACCESS_METHOD: item.accessMethod,
          ALLOCATION: item.allocation,
          ASYNCIO: item.asyncIO,
          BLOCK_SIZE: item.blockSize,
          DEFER_ALLOCATE: item.deferAllocate,
          ENCRYPTION_FLAG: item.encryption,
          EXTENSION_COUNT: item.extensionCount,
          GLOBAL_BUFFER_COUNT: item.globalBufferCount,
          LOCK_SPACE: item.lockSpace,
          MUTEX_SLOTS: item.mutexSlots,
          RESERVED_BYTES: item.reservedBytes,
        },
        region: {
          NAME: item.name,
          DYNAMIC_SEGMENT: item.segment,
          AUTODB: item.autodb,
          COLLATION_DEFAULT: item.collationDefault,
          EPOCHTAPER: item.epochTaper,
          INST_FREEZE_ON_ERROR: item.instFreezeOnError,
          JOURNAL: item.journal,
          AUTOSWITCHLIMIT: item.autoSwitchLimit,
          BEFORE_IMAGE: item.beforeImage,
          FILE_NAME: item.journalFileName,
          KEY_SIZE: item.keySize,
          LOCK_CRIT_SEPARATE: item.lockCrit,
          NULL_SUBSCRIPTS: item.nullSubscripts,
          QDBRUNDOWN: item.qDbRundown,
          RECORD_SIZE: item.recordSize,
          STATS: item.stats,
          STDNULLCOLL: item.standardNullCollation,
        },
      };
    },
    okError() {
      const self = this;

      // Reset & Hide the modal - nothing to do here
      self.errors = null;
      self.resetModal();
      self.$refs.modalError.hide();
    },
    cancel() {
      const self = this;

      // Reset the boundItem to the copy we made earlier and hide the modal
      // this.selectedItem = Object.assign(this.boundItem, this.cachedItem);
      self.errors = null;
      self.resetModal();

      // hide all the modals
      self.hideModals();
    },
    focusElement() {
      const self = this;
      self.$refs.infoName.focus();
    },
    resetModal() {
      const self = this;

      // Clear out anything in selected item and set boundItem, CachedItem and selectedIndex to null
      // Only reset if errors isn't set
      if (self.errors === null) {
        self.selectedItem = {
          name: {
            NAME: '',
            REGION: 'DEFAULT',
          },
          segment: {
            NAME: '',
            FILE_NAME: '',
            ACCESS_METHOD: 'BG',
            ALLOCATION: 100,
            ASYNCIO: false,
            BLOCK_SIZE: 1024,
            DEFER_ALLOCATE: true,
            ENCRYPTION_FLAG: false,
            EXTENSION_COUNT: 100,
            GLOBAL_BUFFER_COUNT: 1024,
            LOCK_SPACE: 40,
            MUTEX_SLOTS: 1024,
            RESERVED_BYTES: 0,
          },
          region: {
            NAME: '',
            DYNAMIC_SEGMENT: 'DEFAULT',
            AUTODB: false,
            COLLATION_DEFAULT: 0,
            EPOCHTAPER: true,
            INST_FREEZE_ON_ERROR: false,
            JOURNAL: false,
            AUTOSWITCHLIMIT: '',
            BEFORE_IMAGE: false,
            FILE_NAME: '',
            KEY_SIZE: 64,
            LOCK_CRIT_SEPARATE: true,
            NULL_SUBSCRIPTS: 'ALWAYS',
            QDBRUNDOWN: false,
            RECORD_SIZE: 256,
            STATS: true,
            STDNULLCOLL: true,
          },
        };
        self.boundItem = null;
        self.cachedItem = null;
        self.selectedIndex = null;
      }
    },
    makeitems() {
      const self = this;

      // Builds a filled out items array combining information in regions, segments, and names
      const newItems = [];
      Object.keys(self.names).forEach((name) => {
        if (name === '#') {
          self.displayName = 'Local Locks';
        } else {
          self.displayName = name;
        }
        const displayItem = {
          displayName: self.displayName,
          name,
          region: self.names[name],
          segment: self.regions[self.names[name]].DYNAMIC_SEGMENT,
          file: self.segments[self.regions[self.names[name]].DYNAMIC_SEGMENT].FILE_NAME,
        };
        newItems.push(displayItem);
      });
      self.items = Object.assign([], newItems);

      // Build items array for regions
      const newRegions = [];
      Object.keys(self.regions).forEach((name) => {
        const displayRegion = {
          name,
          segment: self.regions[name].DYNAMIC_SEGMENT,
          defaultCollation: self.regions[name].COLLATION_DEFAULT,
          recordSize: self.regions[name].RECORD_SIZE,
          keySize: self.regions[name].KEY_SIZE,
          nullSubscripts: self.regions[name].NULL_SUBSCRIPTS,
          standardNullCollation: self.regions[name].STDNULLCOLL,
          journal: self.regions[name].JOURNAL,
          instFreezeOnError: self.regions[name].INST_FREEZE_ON_ERROR,
          qDbRundown: self.regions[name].QDBRUNDOWN,
          epochTaper: self.regions[name].EPOCHTAPER,
          autodb: self.regions[name].AUTODB,
          stats: self.regions[name].STATS,
          lockCrit: self.regions[name].LOCK_CRIT_SEPARATE,
          journalFileName: self.regions[name].FILE_NAME,
          beforeImage: self.regions[name].BEFORE_IMAGE,
          bufferSize: self.regions[name].BUFFER_SIZE,
          allocation: self.regions[name].ALLOCATION,
          extensionCount: self.regions[name].EXTENSION,
          autoSwitchLimit: self.regions[name].AUTOSWITCHLIMIT,
        };
        newRegions.push(displayRegion);
      });
      self.regionItems = Object.assign([], newRegions);

      // Build items array for segments
      const newSegments = [];
      Object.keys(self.segments).forEach((name) => {
        const displaySegment = {
          name,
          fileName: self.segments[name].FILE_NAME,
          accessMethod: self.segments[name].ACCESS_METHOD,
          type: self.segments[name].FILE_TYPE,
          allocation: self.segments[name].ALLOCATION,
          blockSize: self.segments[name].BLOCK_SIZE,
          extensionCount: self.segments[name].EXTENSION_COUNT,
          globalBufferCount: self.segments[name].GLOBAL_BUFFER_COUNT,
          lockSpace: self.segments[name].LOCK_SPACE,
          reservedBytes: self.segments[name].RESERVED_BYTES,
          encryption: self.segments[name].ENCRYPTION_FLAG,
          mutexSlots: self.segments[name].MUTEX_SLOTS,
          deferAllocate: self.segments[name].DEFER_ALLOCATE,
          asyncIO: self.segments[name].ASYNCIO,
        };
        newSegments.push(displaySegment);
      });
      self.segmentItems = Object.assign([], newSegments);
    },
    ok(type) {
      let item;
      const self = this;
      self.saved = false;
      self.savedToggle = !self.saved;

      // Move data from the modal to the correct object behind the scenes
      switch (type) {
        case 'name':
          self.names[self.selectedItem.name.NAME] = self.selectedItem.name.REGION;
          self.unsavedItems.names.push(self.selectedItem.name.NAME);
          break;
        case 'segment':
          item = Object.assign({}, self.selectedItem.segment);
          delete item.NAME;
          self.segments[self.selectedItem.segment.NAME] = item;
          self.unsavedItems.segments.push(self.selectedItem.segment.NAME);
          break;
        case 'region':
          item = Object.assign({}, self.selectedItem.region);
          delete item.NAME;
          self.regions[self.selectedItem.region.NAME] = item;
          self.unsavedItems.regions.push(self.selectedItem.region.NAME);
          break;
        default:
          break;
      }

      // Verify the data, but don't save it
      self.verifydata();

      // hide all the modals
      self.hideModals();
    },
    hideModals() {
      const self = this;

      // Put all modals here to be hidden when OK or Cancel is pressed
      self.$refs.modalAdd.hide();
      self.$refs.modalEditName.hide();
      self.$refs.modalEditRegion.hide();
      self.$refs.modalEditSegment.hide();
    },
    remove(item, type) {
      const self = this;
      let index = 0;
      let unsavedItemsIndex = 0;
      self.saved = false;
      self.savedToggle = !self.saved;

      switch (type) {
        case 'name':
          unsavedItemsIndex = self.unsavedItems.names.findIndex(name => name === item.name);
          if (unsavedItemsIndex === -1) {
            self.deletedItems.push({
              name: {
                NAME: item.name,
              },
            });
          } else {
            self.unsavedItems.names.splice(unsavedItemsIndex, 1);
          }
          delete self.names[item.name];
          index = self.items.findIndex(name => name.name === item.name);
          self.items.splice(index, 1);
          break;
        case 'segment':
          // disable eslint max-len for next line so it looks like all other findIndex calls
          /* eslint-disable max-len */
          unsavedItemsIndex = self.unsavedItems.segments.findIndex(segment => segment === item.name);
          if (unsavedItemsIndex === -1) {
            self.deletedItems.push({
              segment: {
                SEGMENT: item.name,
              },
            });
          } else {
            self.unsavedItems.segments.splice(unsavedItemsIndex, 1);
          }
          delete self.segments[item.name];
          index = self.segmentItems.findIndex(segment => segment.name === item.name);
          self.segmentItems.splice(index, 1);
          break;
        case 'region':
          unsavedItemsIndex = self.unsavedItems.regions.findIndex(region => region === item.name);
          if (unsavedItemsIndex === -1) {
            self.deletedItems.push({
              region: {
                REGION: item.name,
              },
            });
          } else {
            self.unsavedItems.regions.splice(unsavedItemsIndex, 1);
          }
          delete self.regions[item.name];
          index = self.regionItems.findIndex(region => region.name === item.name);
          self.regionItems.splice(index, 1);
          break;
        default:
          break;
      }
    },
    getdata() {
      const self = this;
      axios({
        method: 'GET',
        url: '/get',
      }).then((result) => {
        self.names = result.data.names;
        self.regions = result.data.regions;
        self.segments = result.data.segments;
        self.accessMethods = result.data.accessMethods;
        self.map = result.data.map;
        self.makeitems();
      }, (error) => {
        self.errors = JSON.stringify(error);
        self.$refs.modalError.show();
      });
      self.verified = true;
    },
    verifydata() {
      const self = this;
      self.verified = false;

      axios({
        method: 'POST',
        url: '/verify',
        data: {
          names: self.names,
          regions: self.regions,
          segments: self.segments,
        },
      }).then((result) => {
        if (result.data.verifyStatus) {
          self.verified = true;
          return Promise.resolve(self.makeitems());
        }
        if ((!self.fromSave) &&
           (result.data.errors.length === 1) &&
           (result.data.errors[0].includes('GDE-I-MAPBAD'))) {
          self.verified = true;
          return Promise.resolve(self.makeitems());
        }
        return Promise.reject(result.data.errors);
      }).catch((error) => {
        if (!self.errors) {
          self.errors = JSON.stringify(error);
        }
        switch (self.addType) {
          case 'name':
            delete self.names[self.selectedItem.name.NAME];
            break;
          case 'segment':
            delete self.segments[self.selectedItem.segment.NAME];
            break;
          case 'region':
            delete self.regions[this.selectedItem.region.NAME];
            break;
          default:
            break;
        }
        self.verified = false;
        self.$refs.modalError.show();
      });
      self.verified = true;
    },
    async savedata() {
      const self = this;
      axios({
        method: 'POST',
        url: '/save',
        data: {
          names: self.names,
          regions: self.regions,
          segments: self.segments,
          deletedItems: self.deletedItems,
        },
      }).then((result) => {
        self.deletedItems = [];
        self.fromSave = true;
        if (result.data.verifyStatus) {
          self.getdata();
          self.verified = true;
          self.modified = false;
          self.saved = true;
          self.savedToggle = !self.saved;
          self.fromSave = false;
          self.unsavedItems = {
            names: [],
            regions: [],
            segments: [],
          };
          return Promise.resolve(true);
        }
        self.fromSave = false;
        return Promise.reject(result.data.errors);
      }).catch((error) => {
        self.deletedItems = [];
        if (!self.errors) {
          self.errors = JSON.stringify(error);
        }
        self.saved = false;
        self.saved = !self.saved;
        self.verified = false;
        self.$refs.modalError.show();
      });
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
.fixed-header {
  position: fixed;
  top: 148px;
  right: 0;
  left: 0;
  z-index: 9;
  padding-top: 5px;
  padding-bottom: 5px;
  background: white;
}
.table td, .table th {
  padding: .25rem;
}
.alert-danger {
  color: #fff;
  background-color: #c82333;
  border-color: #bd2130;
}
.btn-secondary.active {
  background-color: #f77825 !important;
  border-color: #f77825 !important;
}
</style>
