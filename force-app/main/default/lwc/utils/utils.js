import { ShowToastEvent } from 'lightning/platformShowToastEvent';


/**
 * showtoast event
 * @param variant
 * @param mode
 * @param title
 * @param message
 * @returns {ShowToastEvent}
 */
const showToast = (variant = 'info', mode = 'dismissable', title, message) => {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode : mode
    });
    return event;
}

/** export the functions */
export { showToast };