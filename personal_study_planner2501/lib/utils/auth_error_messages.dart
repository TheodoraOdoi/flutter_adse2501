// File to display the various error messages for authentication

import 'package:supabase_flutter/supabase_flutter.dart';

// Function to display the error message
String getAuthErrorMessage(Object error)
{
  if(error is AuthException)
  {
    switch(error.code)
    {
      case 'invalid_credentials':
        return 'The email address or password is incorrect';

      case 'email_not_confirmed':
        return 'Please verify your email address before signing in.';

      case 'email_exist':
      case 'user_already_exists':
        return 'An account with this email already exist.';

      case 'week_password'  :
      case 'password_too_weak'  :
        return 'The password is too weak. Kindly choose a stronger password';

      case 'otp_expired':
        return 'The verification code has expired';

      case 'otp_disabled'  :
        return 'Email verification is currently unavailable';

      case 'over_request_rate_limit' :
      case 'over_email_send_rate_limit' :
        return 'Too many requests were made. Please wait a little and try again';

      case 'session_expired' :
        return 'Your session has expired. Please login/sign-in again';

      case 'network_error' :
        return 'A network error occurred. Please check your internet connection.';

      default:
        if(error.statusCode == '429'){
          return 'Too many requests were made. Please wait and try again';
        }
        return 'We could not complete the authentication request.';
    }
  }

  if(error is AuthRetryableFetchException){
    return 'The authentication service could not be reached. please check your connection';
  }
  return 'Something went wrong. Please try again.';
}
