<template>
  <Popper arrow>
    <button
      class="calendar__day-button"
      v-bind:class="{
        'auto-adjusted': autoAdjusted && props.exist
      }">
      <span v-if="props.date.schedule === 'full-time'">
        <img :src="fullTime" alt="fullTime" class="schedule-icon" />
      </span>
      <span v-else-if="props.date.schedule === 'morning'">
        <img :src="morning" alt="morning" class="schedule-icon" />
      </span>
      <span v-else-if="props.date.schedule === 'afternoon'">
        <img :src="afterNoon" alt="afternoon" class="schedule-icon" />
      </span>
      <span v-else-if="props.date.schedule === 'off'">
        <img :src="off" alt="off" class="schedule-icon" />
      </span>
      <span v-else-if="props.date.schedule === 'paidleave'">
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
      </button>
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
import { FetchRequest } from '@rails/request.js'

const props = defineProps({
  date: Object,
  autoAdjusted: Boolean,
  exist: Boolean
})
const emit = defineEmits(['update', 'delete'])
const dayOfSchedule = ref('')
function changeSchedule(schedule) {
  if (schedule === 'none') {
    deleteDate()
  } else {
    updateCalendar(schedule)
  }
  dayOfSchedule.value = schedule
}
async function deleteDate() {
  const date = props.date
  if (props.autoAdjusted) {
    emit('delete', date)
    return
  }
  const request = new FetchRequest(
    'delete',
    `api/v1/days/${date.year}/${date.month}/${date.date}`
  )
  const response = await request.perform()
  if (response.ok) {
    emit('delete', date)
  }
}
async function updateCalendar(schedule) {
  const date = props.date
  const dateState = {
    year: date.year,
    month: date.month,
    date: date.date,
    schedule: schedule
  }
  if (props.autoAdjusted) {
    emit('update', dateState)
    return
  }
  const request = new FetchRequest(
    'post',
    `api/v1/days/${date.year}/${date.month}`,
    { body: JSON.stringify(dateState) }
  )
  const response = await request.perform()
  if (response.ok) {
    emit('update', dateState)
  }
}
</script>
<style scoped>
.calendar__day-button {
  width: 45px;
  height: 45px;
  padding: 1px;
}
.schedule-icon {
  width: 40px;
  height: 40px;
}
.auto-adjusted {
  background-color: lightskyblue;
}
</style>
