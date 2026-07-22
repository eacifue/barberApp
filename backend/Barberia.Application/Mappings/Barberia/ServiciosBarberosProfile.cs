using AutoMapper;
using Barberia.Application.DTOs.Barberos;
using Barberia.Application.DTOs.Servicios;
using Barberia.Domain.Entities;

namespace Barberia.Application.Mappings.Barberia;

public class ServiciosBarberosProfile : Profile
{
    public ServiciosBarberosProfile()
    {
        CreateMap<Servicio, ServicioDto>()
            .ForMember(dest => dest.Tipo, opt => opt.MapFrom(src => src.Tipo.ToString()));

        CreateMap<Barbero, BarberoDto>();

        CreateMap<HorarioSemana, HorarioSemanaDto>()
            .ForMember(dest => dest.DiaSemana, opt => opt.MapFrom(src => src.DiaSemana.ToString()));
    }
}
