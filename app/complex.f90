program complex
  use communicator, only: communicator_t
  use iso_fortran_env, only: team_type

  implicit none

  integer, parameter :: RED = 1, BLUE = 2

  type(communicator_t) :: comm
  character(len=20) :: message[*]
  integer :: me, ni, my_team_num
  class(*), allocatable :: payload
  type(team_type) :: my_team

  call comm%init()
  me = this_image()
  ni = num_images()
  if (me == ni) then
    write(message, "(A,I0,A)") "Hello initial team"
  else
    call comm%receive_from(me+1, payload)
    select type (payload)
    type is (character(len=*))
      message = payload
    class default
      message = "Didn't get a string message"
    end select
  end if
  if (me > 1) call comm%send_to(me-1, message)
  critical
    print *, "Received message '" // trim(message) &
        // "' on image ", me, " of the initial team"
  end critical
  my_team_num = which_team(me)
  form team (my_team_num, my_team)
  change team (my_team)
  block
    integer :: me_now, ni_now
    type(communicator_t) :: inner_comm

    call inner_comm%init()
    me_now = this_image()
    ni_now = num_images()
    if (me_now == 1) then
      message = team_message(my_team_num)
    else
      call inner_comm%receive_from(me_now-1, payload)
      select type (payload)
      type is(character(len=*))
        message = payload
      class default
        message = "Didn't get a string message"
      end select
    end if
    if (me_now < ni_now) call inner_comm%send_to(me_now+1, message)
    critical
      print *, "Received message '" // trim(message) &
          // "' on image ", me_now, " of team " &
          // team_string(my_team_num)
    end critical
  end block
  end team
contains
  pure function which_team(im_num)
    integer, intent(in) :: im_num
    integer :: which_team

    which_team = merge(RED, BLUE, mod(im_num, 2) == 0)
  end function

  pure function team_message(team_num)
    integer, intent(in) :: team_num
    character(len=:), allocatable :: team_message

    if (team_num == RED) then
        team_message = "Red Team Rules!"
    else
        team_message = "Go Team Blue!"
    end if
  end function

  pure function team_string(team_num)
    integer, intent(in) :: team_num
    character(len=:), allocatable :: team_string

    if (team_num == RED) then
        team_string = "Red"
    else
        team_string = "Blue"
    end if
  end function
end program