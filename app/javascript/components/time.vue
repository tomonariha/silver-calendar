<template>
  <div class="m-2">
    <span class="add-colon me-2">{{ schedules[props.dayOfSchedule] }}</span>
    <select v-model.number="workingTimes[`${props.dayOfSchedule}StartHour`]">
      <option
        v-for="hour in 24"
        :key="hour"
        :value="hour - 1"
        :selected="
          hour - 1 === workingTimes[`${props.dayOfSchedule}StartHour`]
        ">
        {{ formatTimeNumber(hour - 1) }}
      </option>
    </select>
    <span>時</span>
    <select v-model.number="workingTimes[`${props.dayOfSchedule}StartMinit`]">
      <option
        v-for="minit in minits"
        :key="minit"
        :value="minit"
        :selected="minit === workingTimes[`${props.dayOfSchedule}StartMinit`]">
        {{ formatTimeNumber(minit) }}
      </option>
    </select>
    <span>分〜</span>
    <select v-model.number="workingTimes[`${props.dayOfSchedule}EndHour`]">
      <option
        v-for="hour in 24"
        :key="hour - 1"
        :value="hour - 1"
        :selected="hour - 1 === workingTimes[`${props.dayOfSchedule}EndHour`]">
        {{ formatTimeNumber(hour - 1) }}
      </option>
    </select>
    <span>時</span>
    <select v-model.number="workingTimes[`${props.dayOfSchedule}EndMinit`]">
      <option
        v-for="minit in minits"
        :key="minit"
        :value="minit"
        :selected="minit === workingTimes[`${props.dayOfSchedule}EndMinit`]">
        {{ formatTimeNumber(minit) }}
      </option>
    </select>
    <span>分</span>
  </div>
</template>

<script setup>
import { inject } from 'vue'
const props = defineProps({
  dayOfSchedule: String
})
const schedules = { morning: '午前', afterNoon: '午後', fullTime: '全日' }
const workingTimes = inject('workingTimes')
const minits = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
function formatTimeNumber(i) {
  return i.toString().padStart(2, '0')
}
</script>
