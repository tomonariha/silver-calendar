<template>
  <span>{{props.dayOfSchedule}}</span>
  <select v-model="selectedStartHour" v-on:change="updateStartHour">
    <option v-for="hour in 24" :key="hour">
      {{ hour -1 }}
    </option>
  </select>
  <span>時</span>
  <select v-model="selectedStartMinit" v-on:change="updateStartMinit">
    <option v-for="minit in 60" :key="minit">
      {{ minit -1 }}
    </option>
  </select>
  <span>分〜</span>
  <select v-model="selectedEndHour" v-on:change="updateEndHour">
    <option v-for="hour in 24" :key="hour">
      {{ hour -1 }}
    </option>
  </select>
  <span>時</span>
  <select v-model="selectedEndMinit" v-on:change="updateEndMinit">
    <option v-for="minit in 60" :key="minit">
      {{ minit -1 }}
    </option>
  </select>
  <span>分</span>
  <br>
</template>

<script setup>
import { ref, onMounted } from 'vue'
const props = defineProps({
  dayOfSchedule: String,
  selectedStartHour: Number,
  selectedStartMinit: Number,
  selectedEndHour: Number,
  selectedEndMinit: Number,
})
onMounted(() => {
  selectedStartHour.value = props.selectedStartHour,
  selectedStartMinit.value = props.selectedStartMinit,
  selectedEndHour.value = props.selectedEndHour,
  selectedEndMinit.value = props.selectedEndMinit
})
const emit = defineEmits(['selectedStartHour', 'startMinit', 'endHour', 'endMinit'])
const selectedStartHour = ref(0)
const selectedStartMinit = ref(0)
const selectedEndHour = ref(0)
const selectedEndMinit = ref(0)
function updateStartHour() {
  emit('selectedStartHour', selectedStartHour)
}
function updateStartMinit() {
  emit('selectedStartMinit', selectedStartMinit)
}
function updateEndHour() {
  emit('selectedEndHour', selectedEndHour)
}
function updateEndMinit() {
  emit('selectedEndMinit', selectedEndMinit)
}
</script>
