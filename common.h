/* CPP Macros for error handling */
#define MSG_ERROR(msg) call handle_error(msg, __FILE__, __LINE__)
#define MSG_BUG(msg) call handle_error(msg, __FILE__, __LINE__)

#define CHECK_IERR(ierr) if (ierr /= 0) call handle_error("unknown", __FILE__, __LINE__)
#define CHECK_IERR_MSG(ierr, msg) if (ierr /= 0) call handle_error(msg, __FILE__, __LINE__)
