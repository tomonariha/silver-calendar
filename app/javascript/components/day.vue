<template>
  <Popper arrow>
    <button class="calendar__day-body">{{ currentSchedule() }}</button>
    <template #content>
      <div v-for="scheduleMark in scheduleMarks" :key="scheduleMark">
        <button v-on:click="changeSchedule(scheduleMark)">{{ scheduleMark }}</button>
      </div>
    </template>
  </Popper>
</template>

<script setup>
import { ref } from 'vue'
import Popper from 'vue3-popper'
const dayOfSchedule = ref("")
const scheduleMarks = [ "●", "▲", "△", "□", "指定なし"]
const markToSchedule = { "●":"full-time", "▲":"morning", "△":"afternoon", "□":"off" , "指定なし":"" }
const scheduleToMark = { "full-time":"●", "morning":"▲", "afternoon":"△", "off":"□" }
const props = defineProps({ 
    date: Object,
    autoAdjusted: Boolean})
const emit = defineEmits(['update', 'delete'])
function token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    }
function currentSchedule() {
      return scheduleToMark[props.date.schedule]
    }
function changeSchedule(scheduleMark) {
      if (scheduleMark === "指定なし") {
        deleteDate()
      } else {
        updateCalendar(scheduleMark)
      }
      dayOfSchedule.value = markToSchedule[scheduleMark]
    }
function deleteDate() {
  const date = props.date
      if (props.autoAdjusted) {
        emit('delete', date)
        return
      }
      fetch(`days/${date.year}/${date.month}/${date.date}`, {
      method: 'DELETE',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': token(),
      },
      credentials: 'same-origin'
      })
      .then(() => {
        emit('delete', date)
      })
      .catch((error) => {
        console.warn(error)
      })
    }
function updateCalendar(schedule) {
  const date = props.date
      const dateState = {year: date.year, month: date.month, date: date.date, schedule: markToSchedule[schedule]}
      if (props.autoAdjusted) {
        emit('update', dateState)
        return
      }
      fetch(`days/${date.year}/${date.month}`, {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': token(),
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(dateState),
      credentials: 'same-origin'
      })
      .then(() => {
        emit('update', dateState)
      })
      .catch((error) => {
        console.warn(error)
      })
    }

</script>
