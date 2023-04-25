<template>
  <Popper arrow>
    <button class="calendar__day-button" v-bind:class="{'auto-adjusted': autoAdjusted && !$attrs.class.includes('disabled')}">
      <span v-if="props.date.schedule==='full-time'">
        <img :src="fullTime" alt="fullTime" width="24" height="24"/>
      </span>
      <span v-else-if="props.date.schedule==='morning'">
        <img :src="morning" alt="morning" width="24" height="24"/>
      </span>
      <span v-else-if="props.date.schedule==='afternoon'">
        <img :src="afterNoon" alt="afternoon" width="24" height="24"/>
      </span>
      <span v-else-if="props.date.schedule==='off'">
        <img :src="off" alt="off" width="24" height="24"/>
      </span>
    </button>
    <template #content>
      <button v-on:click="changeSchedule('full-time')">
        <img :src="fullTime" alt="fullTime" width="24" height="24"/>
      </button>
      <button v-on:click="changeSchedule('morning')">
        <img :src="morning" alt="morning" width="24" height="24"/>
      </button>
      <button v-on:click="changeSchedule('afternoon')">
        <img :src="afterNoon" alt="afternoon" width="24" height="24"/>
      </button>
      <button v-on:click="changeSchedule('off')">
        <img :src="off" alt="off" width="24" height="24"/>
      </button>
      <button class="calendar__day-button" v-on:click="changeSchedule('none')">無
      </button>
    </template>
  </Popper>
</template>

<script setup>
import { ref } from 'vue'
import Popper from 'vue3-popper'
import fullTime from '../../assets/images/full-time.svg?url'
import morning from '../../assets/images/morning.svg?url'
import afterNoon from '../../assets/images/afternoon.svg?url'
import off from '../../assets/images/off.svg?url'

const schedules = [ "full-time", "morning", "afternoon", "off", "none"]
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
<style scoped>
  .calendar__day-button{
    width: 32px;
    height: 32px;
    padding: 1px;
  }
  .auto-adjusted{
    background-color: lightskyblue;
  }
</style>