<template>
  <span>{{ schedules[props.dayOfSchedule] }}</span>
  <select v-model.number="workingTimes[`${props.dayOfSchedule}StartHour`]" >
    <option v-for="hour in 24" :key="hour">
      {{ hour -1 }}
    </option>
  </select>
  <span>時</span>
  <select v-model.number="workingTimes[`${props.dayOfSchedule}StartMinit`]">
    <option v-for="minit in minits" :key="minit">
      {{ minit }}
    </option>
  </select>
  <span>分〜</span>
  <select v-model.number="workingTimes[`${props.dayOfSchedule}EndHour`]">
    <option v-for="hour in 24" :key="hour">
      {{ hour -1 }}
    </option>
  </select>
  <span>時</span>
  <select v-model.number="workingTimes[`${props.dayOfSchedule}EndMinit`]">
    <option v-for="minit in minits" :key="minit">
      {{ minit }}
    </option>
  </select>
  <span>分</span>
  <br>
</template>

<script setup>
import { ref, onMounted, inject} from 'vue'
const props = defineProps({
  dayOfSchedule: String
})
const schedules = { 'morning':'午前: ', 'afterNoon':'午後: ', 'fullTime': '全日: ' }
const workingTimes = inject('workingTimes')
const minits = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
</script>
