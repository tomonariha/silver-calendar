import { createApp } from 'vue'
import App from '../app.vue'
import Toast from 'vue-toastification'
import 'vue-toastification/dist/index.css'
import '../stylesheets/styles.scss'

document.addEventListener('DOMContentLoaded', () => {
  const Calendar = document.querySelector('#app')
  const options = {
    timeout: 2000
  }
  createApp(App).use(Toast, options).mount(Calendar)
})
