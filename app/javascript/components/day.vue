<template>
  <Popper arrow>
    <button class="calendar__day-button" v-bind:class="{'auto-adjusted': autoAdjusted && !$attrs.class.includes('disabled')}">
      <span v-if="props.date.schedule==='full-time'">
        <img :src="fullTime" alt="fullTime" class="schedule-icon" />
      </span>
      <span v-else-if="props.date.schedule==='morning'">
        <img :src="morning" alt="morning" class="schedule-icon" />
      </span>
      <span v-else-if="props.date.schedule==='afternoon'">
        <img :src="afterNoon" alt="afternoon" class="schedule-icon" />
      </span>
      <span v-else-if="props.date.schedule==='off'">
        <img :src="off" alt="off" class="schedule-icon" />
      </span>
      <span v-else-if="props.date.schedule==='paidleave'">
        <img :src="paidleave" alt="paidleave" class="schedule-icon" />
      </span>
    </button>
    <template #content>
      <button v-on:click="changeSchedule('full-time')">
        <img :src="fullTime" alt="fullTime" class="schedule-icon" />
      </button>
      <button v-on:click="changeSchedule('morning')">
        <img :src="morning" alt="morning" class="schedule-icon" />
      </button>
      <button v-on:click="changeSchedule('afternoon')">
        <img :src="afterNoon" alt="afternoon" class="schedule-icon" />
      <button v-on:click="changeSchedule('off')">
        <img :src="off" alt="off" class="schedule-icon" />
      </button>
      <button v-on:click="changeSchedule('paidleave')">
        <img :src="paidleave" alt="paidleave" class="schedule-icon" />
      </button>
      <button v-on:click="changeSchedule('none')">
        <img :src="none" alt="none" class="schedule-icon" />
      </button>
    </template>
  </Popper>
</template>

<script setup>
import { ref } from 'vue'
import Popper from 'vue3-popper'
import fullTime from '../../assets/images/fulltime.svg?url'
import morning from '../../assets/images/morning.svg?url'
import afterNoon from '../../assets/images/afternoon.svg?url'
import off from '../../assets/images/off.svg?url'
import paidleave from '../../assets/images/paidleave.svg?url'
import none from '../../assets/images/none.svg?url'

const schedules = [ "full-time", "morning", "afternoon", "off", "paidleave", "none"]
const props = defineProps({ 
  date: Object,
  autoAdjusted: Boolean
})
const emit = defineEmits(['update', 'delete'])
function token() {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta ? meta.getAttribute('content') : ''
}
const dayOfSchedule = ref("")
function changeSchedule(schedule) {
  if (schedule === "none") {
    deleteDate()
  } else {
    updateCalendar(schedule)
  }
  dayOfSchedule.value = schedule
}
function deleteDate() {
  const date = props.date
  if (props.autoAdjusted) {
    emit('delete', date)
    return
  }
  fetch(`api/days/${date.year}/${date.month}/${date.date}`, {
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
  const dateState = {year: date.year, month: date.month, date: date.date, schedule: schedule}
  if (props.autoAdjusted) {
    emit('update', dateState)
    return
  }
  fetch(`api/days/${date.year}/${date.month}`, {
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
<style>
  .calendar__day-button{
    width: 48px;
    height: 48px;
    padding: 1px;
  }
  .schedule-icon{
    width: 42px;
    height: 42px;
  }
  .auto-adjusted{
    background-color: lightskyblue;
  }
</style>
