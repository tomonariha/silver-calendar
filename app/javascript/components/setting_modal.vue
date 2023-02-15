<template>
  <p>モーダル</p>
  <div v-for="setting in settings" :key="setting.id">
    <button v-on:click="reflectSetting(setting)">{{ setting.period_start_at }} 〜 {{ setting.period_end_at }}</button>
    <button v-on:click="deleteSetting(setting.id)">この条件を削除</button>
  </div>
  <button v-on:click="resetSettingParams()">new</button>
  <br>
  <select id="start_month_select" v-model="selectedStartMonth">
    <option v-for="month in 12" :key="month">
      {{ month }}
    </option>
  </select>
  <select id="start_day_select" v-model="selectedStartDay">
    <option v-for="date in this.lastDate(this.selectedStartMonth)" :key="date">
      {{ date }}
    </option>
  </select>
  <br>
  <select id="end_month_select" v-model="selectedEndMonth">
    <option v-for="month in 12" :key="month">
      {{ month }}
    </option>
  </select>
  <select id="end_day_select" v-model="selectedEndDay">
    <option v-for="date in this.lastDate(this.selectedEndMonth)" :key="date">
      {{ date }}
    </option>
  </select>
  <div>この期間の勤務日数:
      <input id="specified_total_days" type="number" v-show="specifiedTotalDays" v-model="totalWorkingDays"/>
  </div>
  <label for="check_specified_total_days">指定しない</label>
  <input type="checkbox" id="check_specified_total_days" v-model="notSpecifiedTotalDays" />
  <div>{{ this.weekdayJp[this.weekdayNumber] }}曜日の予定</div>
  <button @click='previousWeekday'>前</button>
  <button @click='nextWeekday'>後</button>
  <br/>
  <input type="radio" id="none" value="None" v-model="$data['scheduleOf' + this.weekday[this.weekdayNumber]]" />
  <label for="none">予定なし</label>
  <br/>
  <input type="radio" id="full-time" value="full-time" v-model="$data['scheduleOf' + this.weekday[this.weekdayNumber]]" />
  <label for="full-time">全日出勤</label>
  <br/>
  <input type="radio" id="morning" value="morning" v-model="$data['scheduleOf' + this.weekday[this.weekdayNumber]]" />
  <label for="morning">午前出勤</label>
  <br/>
  <input type="radio" id="afternoon" value="afternoon" v-model="$data['scheduleOf' + this.weekday[this.weekdayNumber]]" />
  <label for="afternoon">午後出勤</label>
  <br/>
  <input type="radio" id="off" value="off" v-model="$data['scheduleOf' + this.weekday[this.weekdayNumber]]" />
  <label for="off">休み</label>
  <br/>
  <button v-on:click="$emit('close')">閉じる</button>
  <button v-if="this.settingId" v-on:click="updateSetting(this.settingId)">変更</button>
  <button v-else v-on:click="createSetting()">新規作成</button>
  <p v-if="errors.length">
    <b>Please correct the following error(s):</b>
    <ul>
      <li v-for="error in errors" :key="error.id">{{ error }}</li>
    </ul>
  </p>
</template>

<script lang="ts">
import { defineComponent } from 'vue'

export default defineComponent({
  name: 'Modal',
  data() {
    return {
      scheduleOfSunday: "off",
      scheduleOfMonday: "None",
      scheduleOfTuesday: "None",
      scheduleOfWednesday: "None",
      scheduleOfThursday: "None",
      scheduleOfFriday: "None",
      scheduleOfSaturday: "off",
      selectedStartMonth: "",
      selectedStartDay: "",
      selectedEndMonth: "",
      selectedEndDay: "",
      settingId: "",
      totalWorkingDays: 0,
      notSpecifiedTotalDays: true,
      weekdayNumber: 0,
      weekday: {
        0: "Sunday",
        1: "Monday",
        2: "Tuesday",
        3: "Wednesday",
        4: "Thursday",
        5: "Friday",
        6: "Saturday",
      },
      weekdayJp: {
        0: "日",
        1: "月",
        2: "火",
        3: "水",
        4: "木",
        5: "金",
        6: "土",
      },
      errors: [],
    }
  },
  props: {
    year: { type: Number, reqired: true }, 
    settings: { type: Object, required: true }
  },
  computed: {
    specifiedTotalDays() {
      return !this.notSpecifiedTotalDays
    },
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    lastDate(selectedMonth) {
      const lastDay = new Date(this.year, selectedMonth, 0)
      return lastDay.getDate()
    },
    updateSetting(settingId) {
      const startDay = new Date(this.year, (this.selectedStartMonth - 1), this.selectedStartDay)
      const endDay = new Date(this.year, (this.selectedEndMonth - 1), this.selectedEndDay)
      if (this.totalDaysValidation(startDay, endDay)) { return }
      if (this.periodValidation(startDay, endDay)) { return }
      const setting = {
        period_start_at: startDay.toDateString(),
        period_end_at: endDay.toDateString(),
        total_working_days: this.setTotalWorkingDays(),
        schedule_of_sunday: this.scheduleOfSunday,
        schedule_of_monday: this.scheduleOfMonday,
        schedule_of_tuesday: this.scheduleOfTuesday,
        schedule_of_wednesday: this.scheduleOfWednesday,
        schedule_of_thursday: this.scheduleOfThursday,
        schedule_of_friday: this.scheduleOfFriday,
        schedule_of_saturday: this.scheduleOfSaturday,
      }
      fetch(`api/calendars/${this.year}/settings/${settingId}`, {
      method: 'PUT',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token(),
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(setting),
      credentials: 'same-origin'
      })
      .then(() => {
        setting['id'] = this.settingId
        this.$emit('update', setting)
      })
      .catch((error) => {
        console.warn(error)
      })  
    },
    reflectSetting(setting) {
      const startDay = new Date(setting.period_start_at)
      const endDay = new Date(setting.period_end_at)
      this.totalWorkingDays = setting.total_working_days
      this.scheduleOfSunday = setting.schedule_of_sunday
      this.scheduleOfMonday = setting.schedule_of_monday
      this.scheduleOfTuesday = setting.schedule_of_tuesday
      this.scheduleOfWednesday = setting.schedule_of_wednesday
      this.scheduleOfThursday = setting.schedule_of_thursday
      this.scheduleOfFriday = setting.schedule_of_friday
      this.scheduleOfSaturday = setting.schedule_of_saturday
      this.selectedStartMonth = (startDay.getMonth() + 1)
      this.selectedStartDay = startDay.getDate()
      this.selectedEndMonth = (endDay.getMonth() + 1)
      this.selectedEndDay = endDay.getDate()
      this.settingId = setting.id
      this.weekdayNumber = 0
      if (setting.total_working_days) {
        this.notSpecifiedTotalDays = false
      } else {
        this.notSpecifiedTotalDays = true
      }
    },
    deleteSetting(settingId) {
      fetch(`api/calendars/${this.year}/settings/${settingId}`, {
      method: 'DELETE',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token(),
      },
      credentials: 'same-origin'
      })
      .then(() => {
        this.$emit('delete', settingId)
      })
      .catch((error) => {
        console.warn(error)
      })
    },
    createSetting() {
      const startDay = new Date(this.year, (this.selectedStartMonth - 1), this.selectedStartDay)
      const endDay = new Date(this.year, (this.selectedEndMonth - 1), this.selectedEndDay)
      if (this.totalDaysValidation(startDay, endDay)) { return }
      if (this.periodValidation(startDay, endDay)) { return }
      const setting = {
        period_start_at: startDay.toDateString(),
        period_end_at: endDay.toDateString(),
        total_working_days: this.setTotalWorkingDays(),
        schedule_of_sunday: this.scheduleOfSunday,
        schedule_of_monday: this.scheduleOfMonday,
        schedule_of_tuesday: this.scheduleOfTuesday,
        schedule_of_wednesday: this.scheduleOfWednesday,
        schedule_of_thursday: this.scheduleOfThursday,
        schedule_of_friday: this.scheduleOfFriday,
        schedule_of_saturday: this.scheduleOfSaturday,
      }
      debugger
      fetch(`api/calendars/${this.year}/settings`, {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token(),
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(setting),
      credentials: 'same-origin'
      })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        setting['id'] = json.id
        this.$emit('create', setting)
      })
      .catch((error) => {
        console.warn(error)
      })
    },
    resetSettingParams() {
      this.scheduleOfSunday = "off",
      this.scheduleOfMonday = "None",
      this.scheduleOfTuesday = "None",
      this.scheduleOfWednesday = "None",
      this.scheduleOfThursday = "None",
      this.scheduleOfFriday = "None",
      this.scheduleOfSaturday = "off",
      this.selectedStartMonth = "",
      this.selectedStartDay = "",
      this.selectedEndMonth = "",
      this.selectedEndDay = "",
      this.settingId = "",
      this.totalWorkingDays = 0,
      this.notSpecifiedtotalDays = true
    },
    setTotalWorkingDays() {
      if (this.notSpecifiedTotalDays) { return null } 
      return this.totalWorkingDays
    },
    previousWeekday() {
      if (this.weekdayNumber === 0) {
        this.weekdayNumber = 6
      } else {
        this.weekdayNumber--
      }
    },
    nextWeekday() {
      if (this.weekdayNumber === 6) {
        this.weekdayNumber = 0
      } else {
        this.weekdayNumber++
      }
    },
    periodValidation(startDay, endDay) {
      this.errors = []
      let invalid = false
      if (!this.selectedStartMonth || !this.selectedStartDay || !this.selectedEndMonth || !this.selectedEndDay) {
        this.errors.push("開始日と終了日を入力してください。")
        return true
      }
      if (startDay > endDay) {
        this.errors.push("開始日が終了日以前になるようにしてください。")
        return true
      }
      for (let setting of this.settings) {
        if (setting.id === this.settingId) { continue }
        const settingStartAt = new Date(setting.period_start_at)
        const settingEndAt = new Date(setting.period_end_at)
        if (((startDay <= settingStartAt) && (endDay >= settingStartAt)) ||
          ((startDay <= settingEndAt) && (endDay >= settingEndAt)) ||
          ((startDay > settingStartAt) && (endDay < settingEndAt))) {
          this.errors.push("他の条件の期間と重ならないようにしてください。")
          invalid = true
          break
        }
      }
      if (invalid) { return true }
    },
    totalDaysValidation(startDay, endDay) {
      this.errors = []
      let calendar = []
      for (let day = new Date(startDay.getTime()); day <= endDay; day.setDate(day.getDate()+1)) {
        calendar.push(day)
      }
      if ((this.totalWorkingDays < 0)||(this.totalWorkingDays > calendar.length)) {
        this.errors.push(`勤務日数は０以上期間内の日数(${calendar.length})以下にしてください。`)
        return true
      }
    },
  },
  emits: ['close', 'update', 'create', 'delete']
})
</script>
