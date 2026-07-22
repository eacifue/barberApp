using AutoMapper;
using Barberia.Application.DTOs.Barberias;
using Barberia.Application.DTOs.Clientes;
using Barberia.Domain.Entities;

namespace Barberia.Application.Mappings.Barberia;

public sealed class AdminEntitiesProfile : Profile
{
    public AdminEntitiesProfile()
    {
        CreateMap<Domain.Entities.Barberia, BarberiaDto>()
            .ForMember(dest => dest.HoraApertura, opt => opt.MapFrom(src => src.HoraApertura.ToString("HH:mm")))
            .ForMember(dest => dest.HoraCierre, opt => opt.MapFrom(src => src.HoraCierre.ToString("HH:mm")))
            .ForMember(dest => dest.DiasDescanso, opt => opt.MapFrom(src => src.DiasDescanso.Select(x => x.ToString()).ToList()));

        CreateMap<Cliente, ClienteDto>();
    }
}
