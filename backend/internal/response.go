package internal

type CustomResponse struct {
	Message    string `json:"message"`
	StatusCode int    `json:"status_code"`
}

func NewCustomResponse(msg string, statusCode int) *CustomResponse {
	return &CustomResponse{
		Message:    msg,
		StatusCode: statusCode,
	}
}
