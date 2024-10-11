module card_module
    implicit none
    private
    public :: Card

    type Card
        character(len=:), allocatable :: face
        character(len=:), allocatable :: suit
        integer :: hand_value = 0
    contains
        procedure :: set_hand_value
        procedure :: get_face_value
        procedure :: get_suit_value
        procedure :: get_hand_value  ! Added to retrieve hand_value
        procedure :: to_string
    end type Card

contains


    subroutine set_hand_value(this, hand_value)
        class(Card), intent(inout) :: this
        real(4), intent(in) :: hand_value
    
        this%hand_value = this%hand_value + hand_value
    end subroutine set_hand_value

    function get_face_value(this) result(value)
        class(Card), intent(in) :: this
        integer :: value

        ! SELECT CASE construct
        SELECT CASE (this%face)
            CASE ('2')
                value = 2
            CASE ('3')
                value = 3
            CASE ('4')
                value = 4
            CASE ('5')
                value = 5
            CASE ('6')
                value = 6
            CASE ('7')
                value = 7
            CASE ('8')
                value = 8
            CASE ('9')
                value = 9
            CASE ('10')
                value = 10
            CASE ('J')
                value = 11
            CASE ('Q')
                value = 12
            CASE ('K')
                value = 13
            CASE ('A')
                value = 14
            CASE DEFAULT
                value = 0  ! Default case
        END SELECT
    end function get_face_value

    function get_suit_value(this) result(value)
        class(Card), intent(in) :: this
        real :: value

        ! SELECT CASE construct
        SELECT CASE (this%suit)
            CASE ('D')
                value = 0.1
            CASE ('C')
                value = 0.2
            CASE ('H')
                value = 0.3
            CASE ('S')
                value = 0.4
            CASE DEFAULT
                value = 0.0  ! Default case
        END SELECT
    end function get_suit_value

    function get_hand_value(this) result(value)
        class(Card), intent(in) :: this
        real(4) :: value

        value = this%hand_value
    end function get_hand_value

    function to_string(this) result(card_string)
        class(Card), intent(in) :: this
        character(len=3) :: card_string  ! Adjusted length

        write(card_string, '(A, A)') trim(this%face), trim(this%suit)
    end function to_string

end module card_module