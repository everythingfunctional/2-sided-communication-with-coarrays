module communicator
    use iso_fortran_env, only: team_type

    implicit none
    private
    public :: communicator_t

    type :: communicator_t
        type(team_type), allocatable :: teams(:, :) !! sender, receiver
    contains
        procedure :: init
        procedure :: send_to
        procedure :: receive_from
    end type
contains
    subroutine init(self)
        class(communicator_t), intent(inout) :: self

        type(team_type) :: dummy_team
        integer :: sender, receiver, team_number, new_image_number

        associate(me => this_image(), ni => num_images())
            allocate(self%teams(ni, ni))
            associate(dummy_team_num => ni**2 + 1)
                do sender = 1, ni
                    do receiver = 1, ni
                        if (sender /= receiver) then
                            if (sender == me .or. receiver == me) then
                                team_number = receiver + (sender-1)*ni
                                if (sender == me) then
                                    new_image_number = 1
                                else
                                    new_image_number = 2
                                end if
                            else
                                team_number = dummy_team_num
                                new_image_number = unique_image_num(sender, receiver, me)
                            end if
                            form team (team_number, dummy_team, new_index = new_image_number)
                            if (sender == me .or. receiver == me) then
                                self%teams(sender, receiver) = dummy_team
                            end if
                        end if
                    end do
                end do
            end associate
        end associate
    contains
        pure function unique_image_num(s, r, m) result(num)
            integer, intent(in) :: s, r, m
            integer :: num

            if (s < m) then
                if (r < m) then
                    num = m - 2
                else
                    num = m - 1
                end if
            else
                if (r < m) then
                    num = m - 1
                else
                    num = m
                end if
            end if
        end function
    end subroutine

    subroutine send_to(self, to, payload)
        class(communicator_t), intent(in) :: self
        integer, intent(in) :: to
        class(*), intent(in) :: payload

        call send_receive(self%teams(this_image(), to), payload_in = payload)
    end subroutine

    subroutine receive_from(self, from, payload)
        class(communicator_t), intent(in) :: self
        integer, intent(in) :: from
        class(*), allocatable, intent(out) :: payload

        call send_receive(self%teams(from, this_image()), payload_out = payload)
    end subroutine

    subroutine send_receive(team, payload_in, payload_out)
        type(team_type), intent(in) :: team
        class(*), intent(in), optional :: payload_in
        class(*), allocatable, intent(out), optional :: payload_out

        type :: payload_t
            class(*), allocatable :: val
        end type
        type(payload_t) :: payload

        if (present(payload_in)) payload%val = payload_in
        change team (team)
            call co_broadcast(payload, 1)
        end team
        if (present(payload_out)) call move_alloc(payload%val, payload_out)
    end subroutine
end module
