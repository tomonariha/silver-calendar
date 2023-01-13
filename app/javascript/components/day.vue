<template>
  <Popper arrow>
    <button>{{ currentSchedule() }}</button>
    <template #content>
      <div v-for="scheduleMark in scheduleMarks" :key="scheduleMark">
        <button v-on:click="changeSchedule(scheduleMark)">{{ scheduleMark }}</button>
      </div>
    </template>
  </Popper>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import Popper from 'vue3-popper'

export default defineComponent({
  data() {
    return {
      schedule: "",
      scheduleMarks: ["●" , "▲" , "△" , "□", "指定なし"],
      markToSchedule: { "●":"full-time", "▲":"morning", "△":"afternoon", "□":"off" , "指定なし":"" },
      scheduleToMark: { "full-time":"●", "morning":"▲", "afternoon":"△", "off":"□" },
    }
  },
  props: { 
    date: { type: Object, required: true },
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    currentSchedule() {
      return this.scheduleToMark[this.date.schedule]
    },
    changeSchedule(scheduleMark) {
      if (scheduleMark === "指定なし") {
        this.deleteDate()
      } else {
        this.updateCalendar(scheduleMark)
      }
      this.schedule = this.markToSchedule[scheduleMark]
    },
    deleteDate() {
      fetch(`days/${this.date.year}/${this.date.month}/${this.date.date}`, {
      method: 'DELETE',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token(),
      },
      credentials: 'same-origin'
      })
      .catch((error) => {
        console.warn(error)
      })
      this.$emit('delete', this.date)
    },
    updateCalendar(schedule) {
      const dateState = {year: this.date.year, month: this.date.month, date: this.date.date, schedule: this.markToSchedule[schedule]}
      fetch(`days/${this.date.year}/${this.date.month}`, {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token(),
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(dateState),
      credentials: 'same-origin'
      })
      .catch((error) => {
        console.warn(error)
      })
      this.$emit('update', dateState)
    },
  },
  components: {
    Popper,
  },
  emits: ['update', 'delete']
})
</script>
