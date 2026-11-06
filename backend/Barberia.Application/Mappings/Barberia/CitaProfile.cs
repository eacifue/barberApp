using AutoMapper;
using Barberia.Application.DTOs.Citas;
using Barberia.Domain.Entities;

namespace Barberia.Application.Mappings.Barberia;

public class CitaProfile : Profile
{
    public CitaProfile()
    {
        CreateMap<Cita, CitaDto>()
            .ForMember(dest => dest.Estado, opt => opt.MapFrom(src => src.Estado.ToString()))
            .ForMember(dest => dest.TieneReview, opt => opt.MapFrom(src => src.Review != null));

        CreateMap<Cliente, ClienteCitaDto>();
        CreateMap<Barbero, BarberoCitaDto>();
        CreateMap<Servicio, ServicioCitaDto>();
    }
}
