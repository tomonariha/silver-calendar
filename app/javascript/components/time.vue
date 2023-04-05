<template>
  <p>時間設定(外部カレンダーに反映させる時刻)</p>
  <span>午前：</span>
  <select id="start_morning_hour_select" v-model="selectedMorningStartHour">
    <option v-for="hour in 24" :key="hour">
      {{ hour -1 }}
    </option>
  </select>
  <span>時</span>
  <select id="start_morning_minits_select" v-model="selectedMorningStartMinits">
    <option v-for="minits in 60" :key="minits">
      {{ minits -1 }}
    </option>
  </select>
  <span>分〜</span>
  <select id="end_morning_hour_select" v-model="selectedMorningEndHour">
    <option v-for="hour in 24" :key="hour">
      {{ hour -1 }}
    </option>
  </select>
  <span>時</span>
  <select id="end_morning_minits_select" v-model="selectedMorningEndMinits">
    <option v-for="minits in 60" :key="minits">
      {{ minits -1 }}
    </option>
  </select>
  <span>分</span>
  <br/>
  <span>午後：</span>
  <select id="start_after_noon_hour_select" v-model="selectedAfterNoonStartHour">
    <option v-for="hour in 24" :key="hour">
      {{ hour -1 }}
    </option>
  </select>
  <span>時</span>
  <select id="start_after_noon_minits_select" v-model="selectedAfterNoonStartMinits">
    <option v-for="minits in 60" :key="minits">
      {{ minits -1 }}
    </option>
  </select>
  <span>分〜</span>
  <select id="end_after_noon_hour_select" v-model="selectedAfterNoonEndHour">
    <option v-for="hour in 24" :key="hour">
      {{ hour-1 }}
    </option>
  </select>
  <span>時</span>
  <select id="end_after_noon_minits_select" v-model="selectedAfterNoonEndMinits">
    <option v-for="minits in 60" :key="minits">
      {{ minits -1 }}
    </option>
  </select>
  <span>分</span>
  <br/>
  <span>全日：</span>
  <select id="start_full_time_hour_select" v-model="selectedFullTimeStartHour">
    <option v-for="hour in 24" :key="hour">
      {{ hour -1 }}
    </option>
  </select>
  <span>時</span>
  <select id="start_full_time_minits_select" v-model="selectedFullTimeStartMinits">
    <option v-for="minits in 60" :key="minits">
      {{ minits -1 }}
    </option>
  </select>
  <span>分〜</span>
  <select id="end_full_time_hour_select" v-model="selectedFullTimeEndHour">
    <option v-for="hour in 24" :key="hour">
      {{ hour -1 }}
    </option>
  </select>
  <span>時</span>
  <select id="end_full_time_minits_select" v-model="selectedFullTimeEndMinits">
    <option v-for="minits in 60" :key="minits">
      {{ minits -1 }}
    </option>
  </select>
  <span>分</span>
  <br/>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
const selectedMorningStartHour = ref(8)
const selectedMorningStartMinits = ref(0)
const selectedMorningEndHour = ref(12)
const selectedMorningEndMinits = ref(0)
const selectedAfterNoonStartHour = ref(13)
const selectedAfterNoonStartMinits = ref(0)
const selectedAfterNoonEndHour = ref(17)
const selectedAfterNoonEndMinits = ref(0)
const selectedFullTimeStartHour = ref(8)
const selectedFullTimeStartMinits = ref(0)
const selectedFullTimeEndHour = ref(17)
const selectedFullTimeEndMinits = ref(0)
</script>
