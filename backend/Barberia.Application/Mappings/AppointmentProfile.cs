using AutoMapper;
using Barberia.Application.DTOs.Appointments;
using Barberia.Domain.Entities;

namespace Barberia.Application.Mappings;

public class AppointmentProfile : Profile
{
    public AppointmentProfile()
    {
        CreateMap<CreateAppointmentRequest, Appointment>();

        CreateMap<Appointment, AppointmentResponse>()
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()));
    }
}
